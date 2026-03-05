import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/storage/local_storage.dart';
import 'package:networkhub/features/auth/providers/auth_provider.dart';

class SettingsState {
  final String name;
  final String email;
  final String signature;
  final String? defaultTemplateId;
  final bool isLoading;
  final bool isSaved;
  final String? errorMessage;

  const SettingsState({
    this.name = '',
    this.email = '',
    this.signature = '',
    this.defaultTemplateId,
    this.isLoading = false,
    this.isSaved = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? name,
    String? email,
    String? signature,
    String? defaultTemplateId,
    bool? isLoading,
    bool? isSaved,
    String? errorMessage,
    bool clearTemplate = false,
  }) {
    return SettingsState(
      name: name ?? this.name,
      email: email ?? this.email,
      signature: signature ?? this.signature,
      defaultTemplateId:
          clearTemplate ? null : defaultTemplateId ?? this.defaultTemplateId,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: errorMessage,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await LocalStorage.getUserName() ?? '';
    final email = await LocalStorage.getUserEmail() ?? '';
    final signature = await LocalStorage.getUserSignature() ?? '';
    final templateId = await LocalStorage.getDefaultTemplateId();

    // Also try from auth provider
    final user = _ref.read(authProvider).valueOrNull;
    state = state.copyWith(
      name: user?.name ?? name,
      email: user?.email ?? email,
      signature: user?.signature ?? signature,
      defaultTemplateId: user?.defaultTemplateId ?? templateId,
    );
  }

  void updateName(String name) => state = state.copyWith(name: name);
  void updateSignature(String sig) => state = state.copyWith(signature: sig);
  void updateDefaultTemplate(String? id) {
    if (id == null) {
      state = state.copyWith(clearTemplate: true);
    } else {
      state = state.copyWith(defaultTemplateId: id);
    }
  }

  Future<void> saveSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(authProvider.notifier).updateProfile(
            name: state.name.trim(),
            signature: state.signature.trim(),
            defaultTemplateId: state.defaultTemplateId,
          );

      await LocalStorage.setUserName(state.name.trim());
      await LocalStorage.setUserSignature(state.signature.trim());
      if (state.defaultTemplateId != null) {
        await LocalStorage.setDefaultTemplateId(state.defaultTemplateId!);
      }

      state = state.copyWith(isLoading: false, isSaved: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _ref.read(authProvider.notifier).logout();
  }

  void clearSavedState() {
    state = state.copyWith(isSaved: false);
  }
}
