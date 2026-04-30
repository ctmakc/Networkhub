import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityNotifier extends AsyncNotifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  Future<ConnectivityStatus> build() async {
    _subscription?.cancel();

    final results = await Connectivity().checkConnectivity();
    final initial = _mapResults(results);

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      state = AsyncData(_mapResults(results));
    });

    ref.onDispose(() => _subscription?.cancel());

    return initial;
  }

  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  Future<bool> checkIsOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.every((r) => r == ConnectivityResult.none);
  }
}

final connectivityProvider =
    AsyncNotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
  ConnectivityNotifier.new,
);

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.maybeWhen(
    data: (status) => status == ConnectivityStatus.online,
    orElse: () => true,
  );
});
