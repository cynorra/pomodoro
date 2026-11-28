import 'dart:math';

enum TileColor { red, blue, black, yellow }

class OkeyTile {
  final int id;
  final TileColor color;
  final int number; // 1..13 (0 for false joker)
  final bool isFalseJoker;

  const OkeyTile({
    required this.id,
    required this.color,
    required this.number,
    this.isFalseJoker = false,
  });

  String get colorShort => switch (color) {
        TileColor.red => 'K',
        TileColor.blue => 'M',
        TileColor.black => 'S',
        TileColor.yellow => 'R',
      };

  String get label => isFalseJoker ? '★' : '$colorShort$number';

  bool matchesOkey(OkeyTile okeyRef) =>
      !isFalseJoker && color == okeyRef.color && number == okeyRef.number;
}

class MeldEvaluation {
  final int totalPoints;
  final int meldCount;
  final Set<int> meldedTileIds;

  const MeldEvaluation({
    required this.totalPoints,
    required this.meldCount,
    required this.meldedTileIds,
  });

  bool get canOpen101 => totalPoints >= 101;
}

class OkeyEngine {
  OkeyEngine._();

  /// Generates a standard 106-tile Okey deck (2 sets of 4 colors x 1..13 + 2 false jokers).
  static List<OkeyTile> createShuffledDeck([Random? rng]) {
    final random = rng ?? Random();
    final deck = <OkeyTile>[];
    var id = 1;
    for (var copy = 0; copy < 2; copy++) {
      for (final color in TileColor.values) {
        for (var n = 1; n <= 13; n++) {
          deck.add(OkeyTile(id: id++, color: color, number: n));
        }
      }
    }
    deck.add(OkeyTile(id: id++, color: TileColor.black, number: 0, isFalseJoker: true));
    deck.add(OkeyTile(id: id++, color: TileColor.red, number: 0, isFalseJoker: true));
    deck.shuffle(random);
    return deck;
  }

  /// Given the indicator tile, returns the Okey (wild) tile specification.
  static OkeyTile okeyForIndicator(OkeyTile indicator) {
    final nextNum = indicator.number == 13 ? 1 : indicator.number + 1;
    return OkeyTile(id: -1, color: indicator.color, number: nextNum);
  }

  /// Sorts a rack into consecutive same-color runs (Seri Diz).
  static List<OkeyTile> sortBySeries(List<OkeyTile> rack) {
    final copy = List<OkeyTile>.from(rack);
    copy.sort((a, b) {
      if (a.isFalseJoker != b.isFalseJoker) return a.isFalseJoker ? 1 : -1;
      final c = a.color.index.compareTo(b.color.index);
      if (c != 0) return c;
      return a.number.compareTo(b.number);
    });
    return copy;
  }

  /// Sorts a rack by number across colors (Renk Diz / Per Diz).
  static List<OkeyTile> sortByNumber(List<OkeyTile> rack) {
    final copy = List<OkeyTile>.from(rack);
    copy.sort((a, b) {
      if (a.isFalseJoker != b.isFalseJoker) return a.isFalseJoker ? 1 : -1;
      final n = a.number.compareTo(b.number);
      if (n != 0) return n;
      return a.color.index.compareTo(b.color.index);
    });
    return copy;
  }

  /// Evaluates valid runs (3+ consecutive same color) and sets (3-4 same number,
  /// distinct colors) in the player's rack to compute live 101 per score.
  static MeldEvaluation evaluateRack(List<OkeyTile> rack, OkeyTile okeyRef) {
    final used = <int>{};
    var total = 0;
    var melds = 0;

    // Effective value for false jokers is the Okey tile's color & number
    final normal = rack
        .where((t) => !t.matchesOkey(okeyRef))
        .map((t) => t.isFalseJoker
            ? OkeyTile(id: t.id, color: okeyRef.color, number: okeyRef.number)
            : t)
        .toList();

    // 1) Find same-color consecutive runs (length >= 3)
    for (final color in TileColor.values) {
      final byNum = <int, List<OkeyTile>>{};
      for (final t in normal.where((x) => x.color == color && !used.contains(x.id))) {
        byNum.putIfAbsent(t.number, () => []).add(t);
      }
      var run = <OkeyTile>[];
      for (var n = 1; n <= 13; n++) {
        final bucket = byNum[n];
        if (bucket != null && bucket.isNotEmpty) {
          run.add(bucket.first);
        } else {
          if (run.length >= 3) {
            melds++;
            for (final t in run) {
              used.add(t.id);
              total += t.number;
            }
          }
          run = [];
        }
      }
      if (run.length >= 3) {
        melds++;
        for (final t in run) {
          used.add(t.id);
          total += t.number;
        }
      }
    }

    // 2) Find same-number distinct-color sets (3 or 4 tiles)
    for (var n = 13; n >= 1; n--) {
      final distinctByColor = <TileColor, OkeyTile>{};
      for (final t in normal.where((x) => x.number == n && !used.contains(x.id))) {
        distinctByColor.putIfAbsent(t.color, () => t);
      }
      if (distinctByColor.length >= 3) {
        melds++;
        for (final t in distinctByColor.values) {
          used.add(t.id);
          total += t.number;
        }
      }
    }

    // 3) Count Okey wilds as high-value bonus (+13 each when melds exist)
    for (final t in rack.where((x) => x.matchesOkey(okeyRef))) {
      used.add(t.id);
      total += 13;
    }

    return MeldEvaluation(
      totalPoints: total,
      meldCount: melds,
      meldedTileIds: used,
    );
  }
}
