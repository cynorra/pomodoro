// Pure rules for the cafe menu: what each item does, how a boost changes the
// points of a session, and how a streak shield covers missed days. Kept free
// of Flutter, Isar and Firebase so it can be unit-tested directly.

enum CafeEffect {
  /// Multiplies the points of the next focus sessions.
  pointBoost,

  /// Keeps the streak alive across a missed day.
  streakShield,
}

class CafeCatalogEntry {
  final String itemId;
  final String nameEn;
  final String nameTr;
  final String icon;
  final int cost;
  final CafeEffect effect;

  /// Point multiplier in percent (150 = +50%, 200 = x2); 0 for non-boosts.
  final int boostPercent;

  /// How many focus sessions a boost lasts.
  final int boostSessions;

  const CafeCatalogEntry({
    required this.itemId,
    required this.nameEn,
    required this.nameTr,
    required this.icon,
    required this.cost,
    required this.effect,
    this.boostPercent = 0,
    this.boostSessions = 0,
  });
}

const cafeCatalog = <CafeCatalogEntry>[
  CafeCatalogEntry(
    itemId: 'tea_green',
    nameEn: 'Green Tea',
    nameTr: 'Yeşil Çay',
    icon: '🍵',
    cost: 25,
    effect: CafeEffect.pointBoost,
    boostPercent: 150,
    boostSessions: 3,
  ),
  CafeCatalogEntry(
    itemId: 'coffee_espresso',
    nameEn: 'Espresso',
    nameTr: 'Espresso',
    icon: '☕',
    cost: 40,
    effect: CafeEffect.pointBoost,
    boostPercent: 200,
    boostSessions: 3,
  ),
  CafeCatalogEntry(
    itemId: 'cake_cheese',
    nameEn: 'Cheesecake',
    nameTr: 'Cheesecake',
    icon: '🍰',
    cost: 100,
    effect: CafeEffect.pointBoost,
    boostPercent: 300,
    boostSessions: 3,
  ),
  CafeCatalogEntry(
    itemId: streakShieldId,
    nameEn: 'Croissant',
    nameTr: 'Kruvasan',
    icon: '🥐',
    cost: 60,
    effect: CafeEffect.streakShield,
  ),
];

const streakShieldId = 'streak_shield';

CafeCatalogEntry? catalogEntry(String itemId) {
  for (final entry in cafeCatalog) {
    if (entry.itemId == itemId) return entry;
  }
  return null;
}

/// A boost that is currently running.
class ActiveBoost {
  final String itemId;
  final int percent;
  final int sessionsLeft;

  const ActiveBoost({
    required this.itemId,
    required this.percent,
    required this.sessionsLeft,
  });

  Map<String, Object> toJson() => {
        'id': itemId,
        'pct': percent,
        'left': sessionsLeft,
      };

  static ActiveBoost? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final pct = json['pct'];
    final left = json['left'];
    if (id is! String || pct is! int || left is! int) return null;
    if (left <= 0 || pct <= 100 || pct > 1000) return null;
    return ActiveBoost(itemId: id, percent: pct, sessionsLeft: left);
  }

  /// The boost after one more focus session used it up; null once spent.
  ActiveBoost? afterSession() => sessionsLeft <= 1
      ? null
      : ActiveBoost(
          itemId: itemId,
          percent: percent,
          sessionsLeft: sessionsLeft - 1,
        );
}

/// Points for a session with an optional boost; a boost never lowers them.
int boostedPoints(int base, ActiveBoost? boost) {
  if (boost == null || base <= 0) return base;
  return (base * boost.percent / 100).round();
}

/// The boost a cafe item starts, or null when the item is not a boost.
ActiveBoost? boostFor(String itemId) {
  final entry = catalogEntry(itemId);
  if (entry == null || entry.effect != CafeEffect.pointBoost) return null;
  return ActiveBoost(
    itemId: itemId,
    percent: entry.boostPercent,
    sessionsLeft: entry.boostSessions,
  );
}

/// What a completed focus session does to the streak.
///
/// [daysSinceLast] is the calendar-day gap to the previous study day (1 means
/// yesterday). Every day in between is a missed day; each one is covered by
/// one shield. If there are not enough shields the streak restarts at 1 and
/// no shield is spent.
({int streak, int shieldsUsed}) streakAfterSession({
  required int storedStreak,
  required int daysSinceLast,
  required int shields,
}) {
  if (daysSinceLast <= 0) return (streak: storedStreak, shieldsUsed: 0);
  final missed = daysSinceLast - 1;
  if (missed == 0) return (streak: storedStreak + 1, shieldsUsed: 0);
  if (shields >= missed) {
    return (streak: storedStreak + 1, shieldsUsed: missed);
  }
  return (streak: 1, shieldsUsed: 0);
}

/// True while a stored streak is still alive, counting shields that would
/// cover the missed days.
bool streakAlive({required int daysSinceLast, required int shields}) =>
    daysSinceLast <= 1 || daysSinceLast - 1 <= shields;

/// Short label for a point multiplier: 200 -> "×2", 150 -> "+50%".
String boostLabel(int percent) =>
    percent % 100 == 0 ? '×${percent ~/ 100}' : '+${percent - 100}%';
