import 'dart:math' as math;

/// Level from lifetime points earned (spending points never lowers it).
/// Level n starts at 50 * (n-1)^2 points: 0, 50, 200, 450, 800, ...
int levelForPoints(int lifetimePoints) {
  if (lifetimePoints <= 0) return 1;
  return math.sqrt(lifetimePoints / 50).floor() + 1;
}

int pointsForLevel(int level) => level <= 1 ? 0 : 50 * (level - 1) * (level - 1);

/// 0.0 to 1.0 progress inside the current level.
double levelProgress(int lifetimePoints) {
  final level = levelForPoints(lifetimePoints);
  final start = pointsForLevel(level);
  final next = pointsForLevel(level + 1);
  return ((lifetimePoints - start) / (next - start)).clamp(0.0, 1.0).toDouble();
}
