// Pure rules for sending treats to friends who are focusing right now. No
// Firebase here, so everything can be unit-tested.

/// A treat that can be sent. Ids and prices match the cafe items.
class GiftItem {
  const GiftItem(this.id, this.emoji, this.cost);

  final String id;
  final String emoji;
  final int cost;
}

const giftItems = [
  GiftItem('coffee_espresso', '☕', 50),
  GiftItem('tea_green', '🍵', 30),
  GiftItem('cake_cheese', '🍰', 100),
];

GiftItem? giftItemById(String id) {
  for (final item in giftItems) {
    if (item.id == id) return item;
  }
  return null;
}

/// A treat that arrived in the inbox.
class Gift {
  const Gift({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.itemId,
    required this.createdAt,
    required this.seen,
  });

  final String id;
  final String fromUid;
  final String fromName;
  final String itemId;
  final DateTime createdAt;
  final bool seen;
}

/// Someone who is in a focus session right now and allowed treats.
class FocusingUser {
  const FocusingUser({
    required this.uid,
    required this.name,
    required this.endsAt,
  });

  final String uid;
  final String name;
  final DateTime endsAt;
}

/// A sender may send one treat to the same friend per slot of this many
/// minutes. The slot is part of the document id, so the security rules can
/// enforce it without a server.
const giftSlotMinutes = 10;

int giftSlot(DateTime now) =>
    now.millisecondsSinceEpoch ~/ (giftSlotMinutes * 60 * 1000);

String giftDocId(String fromUid, String toUid, int slot) =>
    '${fromUid}_${toUid}_$slot';

/// Whole minutes until [endsAt], rounded up, never negative.
int minutesLeft(DateTime endsAt, DateTime now) =>
    ((endsAt.difference(now).inSeconds + 59) ~/ 60).clamp(0, 999);

/// Longest a focus session may be advertised for.
const maxPresenceHours = 3;

/// Gifts that are new since [previousIds] (null = first snapshot, announce
/// nothing individually) and are not from a hidden sender.
List<Gift> giftsToAnnounce({
  required Set<String>? previousIds,
  required List<Gift> current,
  required Set<String> hiddenSenders,
}) {
  if (previousIds == null) return const [];
  return [
    for (final g in current)
      if (!previousIds.contains(g.id) &&
          !g.seen &&
          !hiddenSenders.contains(g.fromUid))
        g,
  ];
}

/// Unread gifts that should count on the bell: hidden senders are ignored.
int unseenCount(List<Gift> gifts, Set<String> hiddenSenders) =>
    gifts.where((g) => !g.seen && !hiddenSenders.contains(g.fromUid)).length;

/// Newest first.
List<Gift> sortedNewestFirst(Iterable<Gift> gifts) =>
    gifts.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
