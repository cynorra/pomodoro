import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/auth_service.dart';
import 'auth_state.dart';

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final subscription = AuthService.authStateChanges.listen((user) {
      state = user != null
          ? AuthState.authenticated(user)
          : AuthState.unauthenticated();
    });
    ref.onDispose(subscription.cancel);

    final current = AuthService.currentUser;
    return current != null
        ? AuthState.authenticated(current)
        : AuthState.initial();
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    final result = await AuthService.signIn(email: email, password: password);
    if (!result.isSuccess) {
      state = AuthState.error(result.errorMessage ?? 'sign-in-failed');
    }
    return result;
  }

  Future<AuthResult> signInWithGoogle() async {
    state = AuthState.loading();
    final result = await AuthService.signInWithGoogle();
    if (!result.isSuccess) {
      state = result.errorMessage == AuthResult.cancelled
          ? AuthState.unauthenticated()
          : AuthState.error(result.errorMessage ?? 'sign-in-failed');
    }
    return result;
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = AuthState.loading();
    final result = await AuthService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (!result.isSuccess) {
      state = AuthState.error(result.errorMessage ?? 'sign-up-failed');
    }
    return result;
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = AuthState.unauthenticated();
  }

  Future<AuthResult> deleteAccount({
    String? email,
    String? password,
    bool reauthWithGoogle = false,
  }) async {
    state = AuthState.loading();
    final result = await AuthService.deleteAccount(
      email: email,
      password: password,
      reauthWithGoogle: reauthWithGoogle,
    );
    if (result.isSuccess) {
      state = AuthState.unauthenticated();
    } else {
      state = AuthState.error(result.errorMessage ?? 'delete-failed');
    }
    return result;
  }
}
