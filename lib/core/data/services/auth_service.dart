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
      return AuthResult.error('Bilinmeyen bir hata oluştu');
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
      return AuthResult.error('Bilinmeyen bir hata oluştu');
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
        return AuthResult.error('Kullanıcı bulunamadı');
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
      return AuthResult.error('Hesap silme başarısız');
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Delete account failed');
      return AuthResult.error('Hesap silme başarısız');
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
      return AuthResult.error('Email gönderilemedi');
    }
  }

  static String get accountDeletionWebUrl => 'https://cynora.com/delete-account';
  static String get privacyPolicyUrl => 'https://cynora.com/privacy';
  static String get termsOfServiceUrl => 'https://cynora.com/terms';

  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu email zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz email adresi';
      case 'weak-password':
        return 'Şifre çok zayıf (en az 6 karakter)';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen sonra tekrar deneyin';
      default:
        return 'Bir hata oluştu';
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
