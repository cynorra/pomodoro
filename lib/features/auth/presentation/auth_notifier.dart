import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/auth_service.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<dynamic>? _authSub;

  AuthNotifier() : super(AuthState.initial()) {
    _init();
  }

  void _init() {
    final current = AuthService.currentUser;
    if (current != null) {
      state = AuthState.authenticated(current);
    }
    _authSub = AuthService.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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

  Future<AuthResult> deleteAccount({String? email, String? password}) async {
    state = AuthState.loading();
    final result = await AuthService.deleteAccount(email: email, password: password);
    if (result.isSuccess) {
      state = AuthState.unauthenticated();
    } else {
      state = AuthState.error(result.errorMessage ?? 'delete-failed');
    }
    return result;
  }
}
