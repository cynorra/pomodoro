import '../../pomodoro/domain/pomodoro_rules.dart';

/// Shown when an account has no usable name.
const anonymousName = 'Anonymous';

/// The name other users see: trimmed, at most 40 characters (what the security
/// rules accept), and never empty.
String displayNameOrFallback(String? name) {
  final cleaned = leaderboardName(name);
  return cleaned.isEmpty ? anonymousName : cleaned;
}
