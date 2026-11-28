import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/okey/domain/okey_engine.dart';

void main() {
  group('OkeyEngine', () {
    test('creates a standard 106-tile deck with 2 false jokers', () {
      final deck = OkeyEngine.createShuffledDeck(Random(42));
      expect(deck.length, 106);
      expect(deck.where((t) => t.isFalseJoker).length, 2);
    });

    test('computes okey tile wrapping 13 -> 1', () {
      const ind10 = OkeyTile(id: 1, color: TileColor.red, number: 10);
      final okey11 = OkeyEngine.okeyForIndicator(ind10);
      expect(okey11.color, TileColor.red);
      expect(okey11.number, 11);

      const ind13 = OkeyTile(id: 2, color: TileColor.blue, number: 13);
      final okey1 = OkeyEngine.okeyForIndicator(ind13);
      expect(okey1.color, TileColor.blue);
      expect(okey1.number, 1);
    });

    test('evaluates runs and sets toward 101 opening threshold', () {
      const okeyRef = OkeyTile(id: -1, color: TileColor.yellow, number: 1);
      const rack = [
        // Red run 10-11-12-13 = 46
        OkeyTile(id: 1, color: TileColor.red, number: 10),
        OkeyTile(id: 2, color: TileColor.red, number: 11),
        OkeyTile(id: 3, color: TileColor.red, number: 12),
        OkeyTile(id: 4, color: TileColor.red, number: 13),
        // Blue run 7-8-9 = 24
        OkeyTile(id: 5, color: TileColor.blue, number: 7),
        OkeyTile(id: 6, color: TileColor.blue, number: 8),
        OkeyTile(id: 7, color: TileColor.blue, number: 9),
        // Set of 11s (Blue, Black, Yellow) = 33 -> total 103 >= 101
        OkeyTile(id: 8, color: TileColor.blue, number: 11),
        OkeyTile(id: 9, color: TileColor.black, number: 11),
        OkeyTile(id: 10, color: TileColor.yellow, number: 11),
      ];

      final eval = OkeyEngine.evaluateRack(rack, okeyRef);
      expect(eval.meldCount, 3);
      expect(eval.totalPoints, 103);
      expect(eval.canOpen101, isTrue);
    });
  });
}
