import '../../../l10n/generated/app_localizations.dart';

/// Maps the error codes produced by AuthService/AuthNotifier to localized text.
String authErrorText(AppLocalizations l10n, String? code) {
  switch (code) {
    case 'user-not-found':
      return l10n.authErrorUserNotFound;
    case 'delete-failed':
      return l10n.authErrorDeleteFailed;
    case 'reset-failed':
      return l10n.authErrorResetFailed;
    case 'email-already-in-use':
      return l10n.authErrorEmailInUse;
    case 'invalid-email':
      return l10n.authErrorInvalidEmail;
    case 'weak-password':
      return l10n.authErrorWeakPassword;
    case 'wrong-password':
      return l10n.authErrorWrongPassword;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    case 'sign-in-failed':
      return l10n.authSignInFailed;
    case 'sign-up-failed':
      return l10n.authSignUpFailed;
    case 'generic':
      return l10n.authErrorGeneric;
    default:
      return l10n.authErrorUnknown;
  }
}
