import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/global_exception_handler.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'displayName': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'totalPoints': 0,
        'totalStudyMinutes': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lifetimePointsEarned': 0,
      });

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      GlobalExceptionHandler.logError(e, e.stackTrace, 'Sign up failed');
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Sign up failed');
      return AuthResult.error('unknown');
    }
  }

  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      GlobalExceptionHandler.logError(e, e.stackTrace, 'Sign in failed');
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Sign in failed');
      return AuthResult.error('unknown');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Sign out failed');
    }
  }

  static Future<AuthResult> deleteAccount({
    String? email,
    String? password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.error('user-not-found');
      }

      if (email != null && password != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await _firestore.collection('leaderboard').doc(user.uid).delete();
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      GlobalExceptionHandler.logError(e, e.stackTrace, 'Delete account failed');
      
      if (e.code == 'requires-recent-login') {
        return AuthResult.error('requires-recent-login');
      }
      return AuthResult.error('delete-failed');
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Delete account failed');
      return AuthResult.error('delete-failed');
    }
  }

  static Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Password reset failed');
      return AuthResult.error('reset-failed');
    }
  }

  static String get accountDeletionWebUrl => 'https://cynorra.github.io/studycafe/delete-account.html';
  static String get privacyPolicyUrl => 'https://cynorra.github.io/studycafe/privacy.html';
  static String get termsOfServiceUrl => 'https://cynorra.github.io/studycafe/terms.html';

  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'email-already-in-use';
      case 'invalid-email':
        return 'invalid-email';
      case 'weak-password':
        return 'weak-password';
      case 'user-not-found':
        return 'user-not-found';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'wrong-password';
      case 'too-many-requests':
        return 'too-many-requests';
      default:
        return 'generic';
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.errorMessage});

  static final success = AuthResult._(isSuccess: true);
  static error(String message) => AuthResult._(isSuccess: false, errorMessage: message);
}
