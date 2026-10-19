import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/social/data/gift_api.dart';
import '../../../features/pomodoro/domain/pomodoro_rules.dart';
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

      final name = leaderboardName(displayName, maxLength: 30);
      await credential.user?.updateDisplayName(name);

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'displayName': name,
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

  static bool _googleInitialized = false;

  static bool get signedInWithGoogle =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
      false;

  /// Shows the Google account picker and returns a Firebase credential.
  /// The web client ID comes from `default_web_client_id`, which the
  /// google-services plugin generates from google-services.json.
  static Future<AuthCredential> _googleCredential() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize();
      _googleInitialized = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing-id-token');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  static Future<AuthResult> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null && (result.additionalUserInfo?.isNewUser ?? false)) {
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': leaderboardName(user.displayName, maxLength: 30),
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'totalPoints': 0,
          'totalStudyMinutes': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'lifetimePointsEarned': 0,
        });
      }
      return AuthResult.success;
    } on GoogleSignInException catch (e, stack) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return AuthResult.error(AuthResult.cancelled);
      }
      GlobalExceptionHandler.logError(e, stack, 'Google sign in failed');
      return AuthResult.error('google-sign-in-failed');
    } on FirebaseAuthException catch (e) {
      GlobalExceptionHandler.logError(e, e.stackTrace, 'Google sign in failed');
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Google sign in failed');
      return AuthResult.error('google-sign-in-failed');
    }
  }

  static Future<void> signOut() async {
    try {
      // Stop advertising a running focus session before the account goes away.
      await FirebaseGiftApi().stopFocus();
      if (_googleInitialized) await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Sign out failed');
    }
  }

  static Future<AuthResult> deleteAccount({
    String? email,
    String? password,
    bool reauthWithGoogle = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.error('user-not-found');
      }

      if (reauthWithGoogle) {
        await user.reauthenticateWithCredential(await _googleCredential());
      } else if (email != null && password != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await _deleteSocialData(user.uid);
      await _firestore.collection('leaderboard').doc(user.uid).delete();
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      return AuthResult.success;
    } on GoogleSignInException catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Delete account failed');
      return AuthResult.error('delete-failed');
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

  /// Removes the focus status and the treats sent to this account. Failures
  /// here must not block deleting the account itself.
  static Future<void> _deleteSocialData(String uid) async {
    try {
      await _firestore.collection('presence').doc(uid).delete();
      final gifts = await _firestore
          .collection('gifts')
          .where('toUid', isEqualTo: uid)
          .get();
      for (final gift in gifts.docs) {
        await gift.reference.delete();
      }
    } catch (_) {}
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

  static const _legalBase = 'https://cynorra.github.io/studycafe/';

  /// Legal pages exist in English and Turkish; [languageCode] picks one.
  static String _legalUrl(String page, String languageCode) =>
      '$_legalBase$page${languageCode == 'tr' ? '-tr' : ''}.html';

  static String accountDeletionWebUrl(String languageCode) =>
      _legalUrl('delete-account', languageCode);
  static String privacyPolicyUrl(String languageCode) =>
      _legalUrl('privacy', languageCode);
  static String termsOfServiceUrl(String languageCode) =>
      _legalUrl('terms', languageCode);

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

  /// Error code for a user-dismissed sign-in; callers should not show it.
  static const cancelled = 'cancelled';

  static final success = AuthResult._(isSuccess: true);
  static AuthResult error(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
