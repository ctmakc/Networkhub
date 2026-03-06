import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:networkhub/core/error/app_exception.dart';
import 'package:networkhub/core/providers/connectivity_provider.dart';
import 'package:networkhub/core/storage/offline_queue.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/contacts_repository.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(contactsRepositoryProvider),
    OfflineQueue(),
    ref,
  );
});

class SyncService {
  final ContactsRepository _repo;
  final OfflineQueue _queue;
  final Ref _ref;
  final _logger = Logger();
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._repo, this._queue, this._ref) {
    _startPeriodicSync();
    _listenToConnectivity();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncPending();
    });
  }

  void _listenToConnectivity() {
    _ref.listen<AsyncValue<ConnectivityStatus>>(connectivityProvider, (_, next) {
      if (next.valueOrNull == ConnectivityStatus.online) {
        syncPending();
      }
    });
  }

  /// Save a draft contact - tries cloud first, falls back to offline queue
  Future<Contact> saveDraft(DraftContact draft) async {
    final isOnline = _ref.read(isOnlineProvider);

    if (isOnline) {
      try {
        return await _repo.createContact(draft.toJson());
      } on NetworkException {
        // Fall through to offline queue
        _logger.w('Network error, saving to offline queue');
      }
    }

    // Save to offline queue
    final id = '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1000000)}';
    final contactDraft = draft.toContactDraft(id);
    await _queue.enqueue(contactDraft);

    // Return a placeholder contact for UI purposes
    return Contact(
      id: contactDraft.id,
      firstName: draft.firstName,
      lastName: draft.lastName,
      email: draft.email,
      phone: draft.phone,
      company: draft.company,
      title: draft.title,
      website: draft.website,
      notes: draft.notes,
      address: draft.address,
      linkedinUrl: draft.linkedinUrl,
      tags: draft.tags,
      eventId: draft.eventId,
    );
  }

  /// Process all pending drafts in the offline queue
  Future<void> syncPending() async {
    if (_isSyncing) return;
    final isOnline = _ref.read(isOnlineProvider);
    if (!isOnline) return;
    if (!_queue.hasPending) return;

    _isSyncing = true;
    _logger.d('Syncing ${_queue.pendingCount} pending contact(s)...');

    try {
      final pending = _queue.getPending();
      for (final draft in pending) {
        try {
          await _repo.createContact(draft.toJson());
          await _queue.remove(draft.id);
          _logger.d('Synced contact: ${draft.fullName}');
        } on NetworkException {
          // Stop syncing if network fails
          _logger.w('Network error during sync, will retry later');
          break;
        } catch (e) {
          // Mark as failed after too many errors
          await _queue.markFailed(draft.id, e.toString());
          _logger.e('Failed to sync contact ${draft.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  int get pendingCount => _queue.pendingCount;

  Stream<BoxEvent> get queueEvents => _queue.events;

  void dispose() {
    _syncTimer?.cancel();
  }
}
