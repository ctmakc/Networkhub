import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/storage/local_storage.dart';
import 'package:networkhub/features/auth/data/auth_repository.dart';
import 'package:networkhub/features/auth/data/auth_models.dart';

enum AuthStep { emailInput, codeSent, authenticated }

class AuthState {
  final AuthStep step;
  final String? email;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.step = AuthStep.emailInput,
    this.email,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    AuthStep? step,
    String? email,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      step: step ?? this.step,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// The main auth provider - returns the current user or null
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  late AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.read(authRepositoryProvider);
    final hasToken = await LocalStorage.hasToken();
    if (!hasToken) return null;

    try {
      return await _repository.getMe();
    } catch (_) {
      // Token invalid or expired
      await LocalStorage.clearToken();
      return null;
    }
  }

  Future<void> requestMagicLink(String email) async {
    await _repository.requestMagicLink(email);
  }

  Future<void> verifyMagicLink(String email, String code) async {
    state = const AsyncLoading();
    try {
      await _repository.verifyMagicLink(email, code);
      final user = await _repository.getMe();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? signature,
    String? defaultTemplateId,
  }) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    state = const AsyncLoading();
    try {
      final updated = await _repository.updateProfile(
        name: name,
        signature: signature,
        defaultTemplateId: defaultTemplateId,
      );
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _repository.logout();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final user = await _repository.getMe();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Login flow state notifier
final loginFlowProvider =
    StateNotifierProvider<LoginFlowNotifier, AuthState>(
  (ref) => LoginFlowNotifier(ref.read(authRepositoryProvider)),
);

class LoginFlowNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  LoginFlowNotifier(this._repository) : super(const AuthState());

  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.requestMagicLink(email);
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.codeSent,
        email: email,
        successMessage: 'A login code has been sent to $email',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    if (state.email == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyMagicLink(state.email!, code);
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.authenticated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid or expired code. Please try again.',
      );
      return false;
    }
  }

  void resetToEmailInput() {
    state = const AuthState();
  }
}
