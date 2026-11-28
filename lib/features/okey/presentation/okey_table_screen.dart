import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/services/sfx_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../domain/okey_engine.dart';
import 'okey_scorecard_sheet.dart';

/// Playable Nocturne Atelier 101 Okey table with wooden rack, draw/discard flow,
/// live per point calculator, and end-of-hand receipt.
class OkeyTableScreen extends StatefulWidget {
  const OkeyTableScreen({super.key});

  @override
  State<OkeyTableScreen> createState() => _OkeyTableScreenState();
}

class _OkeyTableScreenState extends State<OkeyTableScreen> {
  late List<OkeyTile> _deck;
  late OkeyTile _indicator;
  late OkeyTile _okeyRef;
  late List<OkeyTile> _rack;
  OkeyTile? _leftDiscard;
  OkeyTile? _rightDiscard;

  int? _selectedIndex;
  bool _hasDrawnThisTurn = true; // Dealer starts with 15 tiles, must discard
  int _handNumber = 1;
  String _statusText = 'Sıra Sende: Bir taş seç ve Sağa Taş At kutusuna bırak.';

  @override
  void initState() {
    super.initState();
    _dealNewHand();
  }

  void _dealNewHand() {
    final full = OkeyEngine.createShuffledDeck();
    // Pick a non-joker indicator
    final indIdx = full.indexWhere((t) => !t.isFalseJoker);
    _indicator = full.removeAt(indIdx);
    _okeyRef = OkeyEngine.okeyForIndicator(_indicator);
    _rack = OkeyEngine.sortBySeries(full.sublist(0, 15));
    _leftDiscard = full[15];
    _rightDiscard = null;
    _deck = full.sublist(16);
    _selectedIndex = null;
    _hasDrawnThisTurn = true;
    _statusText = 'Sıra Sende: 15 taşla başladın, bir taşı sağa at.';
  }

  void _drawFromDeck() {
    if (_hasDrawnThisTurn || _deck.isEmpty) return;
    HapticFeedback.selectionClick();
    SfxService.play(Sfx.coin);
    setState(() {
      _rack.add(_deck.removeLast());
      _hasDrawnThisTurn = true;
      _selectedIndex = _rack.length - 1;
      _statusText = 'Desteden taş çektin. Şimdi bir taşı Sağa Taş At kutusuna at.';
    });
  }

  void _takeLeftDiscard() {
    if (_hasDrawnThisTurn || _leftDiscard == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _rack.add(_leftDiscard!);
      _leftDiscard = null;
      _hasDrawnThisTurn = true;
      _selectedIndex = _rack.length - 1;
      _statusText = 'Soldaki taşı aldın. Şimdi bir taşı Sağa Taş At kutusuna at.';
    });
  }

  void _discardSelected() {
    if (!_hasDrawnThisTurn || _selectedIndex == null) return;
    HapticFeedback.mediumImpact();
    final thrown = _rack.removeAt(_selectedIndex!);
    setState(() {
      _rightDiscard = thrown;
      _selectedIndex = null;
      _hasDrawnThisTurn = false;
      _statusText = 'Rakipler oynuyor...';
    });

    // Simulate 3 quick quiet opponent turns
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (_deck.length <= 3) {
        _finishHand(userWon: false, finishingTile: thrown.label);
        return;
      }
      setState(() {
        // Each opponent draws from deck; last opponent discards to our left
        _deck.removeLast();
        _deck.removeLast();
        _leftDiscard = _deck.removeLast();
        _statusText = 'Sıra Sende: Ortadan taş çek veya soldaki ${_leftDiscard!.label} taşını al.';
      });
    });
  }

  void _onTileTap(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIndex == null) {
        _selectedIndex = index;
      } else if (_selectedIndex == index) {
        _selectedIndex = null;
      } else {
        // Swap tiles in rack
        final tmp = _rack[_selectedIndex!];
        _rack[_selectedIndex!] = _rack[index];
        _rack[index] = tmp;
        _selectedIndex = null;
      }
    });
  }

  Future<void> _finishHand({
    required bool userWon,
    required String finishingTile,
  }) async {
    final eval = OkeyEngine.evaluateRack(_rack, _okeyRef);
    final playAgain = await showOkeyScorecardSheet(
      context,
      winnerName: userWon ? 'Sen' : 'Selin M.',
      openedScore: eval.totalPoints,
      finishingTile: finishingTile,
      handNumber: _handNumber,
      potCoins: 60,
      userWon: userWon,
    );
    if (!mounted) return;
    if (playAgain == true) {
      setState(() {
        _handNumber = _handNumber >= 4 ? 1 : _handNumber + 1;
        _dealNewHand();
      });
    } else if (playAgain == false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eval = OkeyEngine.evaluateRack(_rack, _okeyRef);
    final topRow = _rack.take(8).toList();
    final bottomRow = _rack.length > 8 ? _rack.sublist(8) : <OkeyTile>[];

    return Scaffold(
      backgroundColor: ZyraColors.feltDark,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masa 08 · Okey Salonu',
              style: ZyraTypography.titleLarge.copyWith(fontSize: 16),
            ),
            Text(
              '101 SESSİZ MOD · EL $_handNumber/4 · POT 60 BAKIR',
              style: ZyraTypography.dataMono.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: NocturnePillBadge(
                label: 'OKEY: ${_okeyRef.label}',
                dotColor: ZyraColors.primary,
                textColor: ZyraColors.primaryBright,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [ZyraColors.feltMid, ZyraColors.feltDark],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top opponent
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: _OpponentPill(
                  initials: 'SM',
                  name: 'Selin M.',
                  meta: '14 Taş · Çift Açmadı',
                ),
              ),

              // Middle felt: Left opponent, Center deck/indicator, Right opponent
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SideDiscardSlot(
                            label: 'SANA ATILAN',
                            tile: _leftDiscard,
                            okeyRef: _okeyRef,
                            highlighted: !_hasDrawnThisTurn && _leftDiscard != null,
                            onTap: _takeLeftDiscard,
                          ),
                          // Center Indicator + Deck
                          GlassCard(
                            color: ZyraColors.background.withValues(alpha: 0.85),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'GÖSTERGE',
                                      style: ZyraTypography.dataMono.copyWith(
                                        fontSize: 9,
                                        color: ZyraColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _TileChip(
                                      tile: _indicator,
                                      okeyRef: _okeyRef,
                                      small: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                GestureDetector(
                                  onTap: _drawFromDeck,
                                  child: Column(
                                    children: [
                                      Text(
                                        'ORTA DESTE',
                                        style: ZyraTypography.dataMono.copyWith(
                                          fontSize: 9,
                                          color: !_hasDrawnThisTurn
                                              ? ZyraColors.primary
                                              : ZyraColors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 44,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: ZyraColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: !_hasDrawnThisTurn
                                                ? ZyraColors.primary
                                                : ZyraColors.hairlineStrong,
                                            width: !_hasDrawnThisTurn ? 1.8 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_rounded,
                                              size: 16,
                                              color: ZyraColors.primary,
                                            ),
                                            Text(
                                              '${_deck.length}',
                                              style: ZyraTypography.dataMono
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _SideDiscardSlot(
                            label: 'SAĞA TAŞ AT',
                            tile: _rightDiscard,
                            okeyRef: _okeyRef,
                            highlighted:
                                _hasDrawnThisTurn && _selectedIndex != null,
                            onTap: _discardSelected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ZyraColors.background.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: ZyraColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          _statusText,
                          textAlign: TextAlign.center,
                          style: ZyraTypography.bodySmall.copyWith(
                            fontSize: 12,
                            color: ZyraColors.primaryBright,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action bar above wooden rack
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Per Toplamı: ${eval.totalPoints} Puan',
                            style: ZyraTypography.dataMono.copyWith(
                              fontSize: 12,
                              color: eval.canOpen101
                                  ? ZyraColors.secondaryBright
                                  : ZyraColors.primaryBright,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '101 Şartı · ${eval.meldCount} Per',
                            style: ZyraTypography.labelSmall.copyWith(
                              fontSize: 10,
                              color: ZyraColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RackToolBtn(
                      label: 'Seri Diz',
                      onTap: () => setState(() {
                        _rack = OkeyEngine.sortBySeries(_rack);
                        _selectedIndex = null;
                      }),
                    ),
                    const SizedBox(width: 6),
                    _RackToolBtn(
                      label: 'Renk Diz',
                      onTap: () => setState(() {
                        _rack = OkeyEngine.sortByNumber(_rack);
                        _selectedIndex = null;
                      }),
                    ),
                    const SizedBox(width: 6),
                    _RackToolBtn(
                      label: 'Eli Aç',
                      primary: true,
                      onTap: () => _finishHand(
                        userWon: true,
                        finishingTile: _okeyRef.label,
                      ),
                    ),
                  ],
                ),
              ),

              // Espresso wood 2-row rack (Istaka)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                decoration: const BoxDecoration(
                  color: ZyraColors.surfaceElevated,
                  border: Border(
                    top: BorderSide(color: ZyraColors.hairlineStrong, width: 1.5),
                  ),
                ),
                child: Column(
                  children: [
                    _RackRow(
                      tiles: topRow,
                      offset: 0,
                      selectedIndex: _selectedIndex,
                      okeyRef: _okeyRef,
                      meldedIds: eval.meldedTileIds,
                      onTap: _onTileTap,
                    ),
                    const SizedBox(height: 8),
                    _RackRow(
                      tiles: bottomRow,
                      offset: 8,
                      selectedIndex: _selectedIndex,
                      okeyRef: _okeyRef,
                      meldedIds: eval.meldedTileIds,
                      onTap: _onTileTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpponentPill extends StatelessWidget {
  final String initials;
  final String name;
  final String meta;

  const _OpponentPill({
    required this.initials,
    required this.name,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ZyraColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ZyraColors.hairlineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: ZyraColors.secondaryContainer,
            child: Text(
              initials,
              style: ZyraTypography.dataMono.copyWith(
                fontSize: 9,
                color: ZyraColors.secondaryBright,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: ZyraTypography.titleMedium.copyWith(fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            meta,
            style: ZyraTypography.dataMono.copyWith(
              fontSize: 10,
              color: ZyraColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideDiscardSlot extends StatelessWidget {
  final String label;
  final OkeyTile? tile;
  final OkeyTile okeyRef;
  final bool highlighted;
  final VoidCallback onTap;

  const _SideDiscardSlot({
    required this.label,
    required this.tile,
    required this.okeyRef,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: ZyraTypography.dataMono.copyWith(
              fontSize: 8.5,
              color: highlighted ? ZyraColors.primary : ZyraColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          if (tile != null)
            _TileChip(
              tile: tile!,
              okeyRef: okeyRef,
              selected: highlighted,
              small: true,
            )
          else
            Container(
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                color: ZyraColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: highlighted
                      ? ZyraColors.primary
                      : ZyraColors.hairlineStrong,
                  width: highlighted ? 1.8 : 1,
                ),
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: highlighted ? ZyraColors.primary : ZyraColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _RackRow extends StatelessWidget {
  final List<OkeyTile> tiles;
  final int offset;
  final int? selectedIndex;
  final OkeyTile okeyRef;
  final Set<int> meldedIds;
  final ValueChanged<int> onTap;

  const _RackRow({
    required this.tiles,
    required this.offset,
    required this.selectedIndex,
    required this.okeyRef,
    required this.meldedIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: ZyraColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZyraColors.hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < tiles.length; i++)
            GestureDetector(
              onTap: () => onTap(offset + i),
              child: _TileChip(
                tile: tiles[i],
                okeyRef: okeyRef,
                selected: selectedIndex == offset + i,
                inMeld: meldedIds.contains(tiles[i].id),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileChip extends StatelessWidget {
  final OkeyTile tile;
  final OkeyTile okeyRef;
  final bool selected;
  final bool inMeld;
  final bool small;

  const _TileChip({
    required this.tile,
    required this.okeyRef,
    this.selected = false,
    this.inMeld = false,
    this.small = false,
  });

  Color get _inkColor => switch (tile.color) {
        TileColor.red => const Color(0xFFB72B2B),
        TileColor.blue => const Color(0xFF1E5AA8),
        TileColor.black => const Color(0xFF1A1614),
        TileColor.yellow => const Color(0xFFC27A14),
      };

  @override
  Widget build(BuildContext context) {
    final isOkey = tile.matchesOkey(okeyRef);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
      width: small ? 42 : 38,
      height: small ? 56 : 52,
      decoration: BoxDecoration(
        color: ZyraColors.tileIvory,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected
              ? ZyraColors.primary
              : (inMeld ? ZyraColors.secondary : const Color(0xFFD6CBB9)),
          width: selected ? 2.2 : (inMeld ? 1.5 : 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.isFalseJoker ? '★' : '${tile.number}',
            style: ZyraTypography.dataMono.copyWith(
              fontSize: small ? 16 : 15,
              fontWeight: FontWeight.w700,
              color: _inkColor,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isOkey ? ZyraColors.primary : _inkColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _RackToolBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _RackToolBtn({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? ZyraColors.primary : ZyraColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary ? ZyraColors.primary : ZyraColors.hairlineStrong,
          ),
        ),
        child: Text(
          label,
          style: ZyraTypography.labelSmall.copyWith(
            fontSize: 11,
            color: primary ? ZyraColors.onPrimary : ZyraColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
