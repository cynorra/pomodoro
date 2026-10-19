import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/social/domain/gift_rules.dart';

Gift g(String id, {String from = 'a', bool seen = false, int minute = 0}) =>
    Gift(
      id: id,
      fromUid: from,
      fromName: 'N',
      itemId: 'tea_green',
      createdAt: DateTime(2026, 1, 1, 10, minute),
      seen: seen,
    );

void main() {
  group('slots and ids', () {
    test('same slot within ten minutes, new slot after', () {
      final t = DateTime.fromMillisecondsSinceEpoch(600000 * 100);
      expect(giftSlot(t), 100);
      expect(giftSlot(t.add(const Duration(minutes: 9, seconds: 59))), 100);
      expect(giftSlot(t.add(const Duration(minutes: 10))), 101);
    });

    test('doc id encodes sender, friend and slot', () {
      expect(giftDocId('mia', 'sam', 7), 'mia_sam_7');
    });
  });

  group('minutesLeft', () {
    final now = DateTime(2026, 1, 1, 10);
    test('rounds up and never goes negative', () {
      expect(minutesLeft(now.add(const Duration(seconds: 1)), now), 1);
      expect(minutesLeft(now.add(const Duration(minutes: 25)), now), 25);
      expect(minutesLeft(now.subtract(const Duration(minutes: 3)), now), 0);
    });
  });

  group('items', () {
    test('lookup by id', () {
      expect(giftItemById('tea_green')?.cost, 30);
      expect(giftItemById('nope'), isNull);
    });
  });

  group('announcing', () {
    test('first snapshot announces nothing individually', () {
      expect(
        giftsToAnnounce(
            previousIds: null, current: [g('1')], hiddenSenders: {}),
        isEmpty,
      );
    });

    test('only new, unseen, non-hidden gifts', () {
      final fresh = giftsToAnnounce(
        previousIds: {'1'},
        current: [
          g('1'),
          g('2'),
          g('3', seen: true),
          g('4', from: 'bad'),
        ],
        hiddenSenders: {'bad'},
      );
      expect([for (final x in fresh) x.id], ['2']);
    });
  });

  group('counts and order', () {
    test('unseen count ignores hidden senders and read gifts', () {
      final list = [g('1'), g('2', seen: true), g('3', from: 'bad')];
      expect(unseenCount(list, {'bad'}), 1);
      expect(unseenCount(list, {}), 2);
    });

    test('newest first', () {
      final sorted =
          sortedNewestFirst([g('old', minute: 1), g('new', minute: 9)]);
      expect([for (final x in sorted) x.id], ['new', 'old']);
    });
  });
}
