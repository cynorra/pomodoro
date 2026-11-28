import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';

/// Nocturne Atelier "Oyun Sonu Hesap Pusulası" bottom sheet.
Future<bool?> showOkeyScorecardSheet(
  BuildContext context, {
  required String winnerName,
  required int openedScore,
  required String finishingTile,
  required int handNumber,
  required int potCoins,
  required bool userWon,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _OkeyScorecardSheet(
      winnerName: winnerName,
      openedScore: openedScore,
      finishingTile: finishingTile,
      handNumber: handNumber,
      potCoins: potCoins,
      userWon: userWon,
    ),
  );
}

class _OkeyScorecardSheet extends StatelessWidget {
  final String winnerName;
  final int openedScore;
  final String finishingTile;
  final int handNumber;
  final int potCoins;
  final bool userWon;

  const _OkeyScorecardSheet({
    required this.winnerName,
    required this.openedScore,
    required this.finishingTile,
    required this.handNumber,
    required this.potCoins,
    required this.userWon,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('E', 'Sen', userWon ? 'GALİP' : '12 Taş', userWon ? '+$potCoins' : '-20', userWon),
      ('S', 'Selin M.', userWon ? '10 Taş Kalan' : 'GALİP', userWon ? '-15' : '+$potCoins', !userWon),
      ('T', 'Tolga K.', '14 Taş · El Açamadı', '-15', false),
      ('A', 'Aylin S.', '14 Taş · El Açamadı', '-10', false),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: ZyraColors.hairlineStrong)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ZyraColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'KAHVEHANE & OKEY ATÖLYESİ',
                style: ZyraTypography.sectionLabel.copyWith(
                  color: ZyraColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NOCTURNE KAFE',
                style: ZyraTypography.headlineMedium.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              NocturnePillBadge(
                label: 'MASA 08 · EL $handNumber/4 · TAMAMLANDI',
                dotColor: ZyraColors.primary,
              ),
              const SizedBox(height: 16),

              // Golden Seal Hero Box
              GlassCard(
                elevated: true,
                padding: const EdgeInsets.all(18),
                border: Border.all(
                  color: ZyraColors.primary.withValues(alpha: 0.45),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: ZyraColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: ZyraColors.onPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$winnerName Eli Kazandı!',
                      style: ZyraTypography.headlineMedium.copyWith(fontSize: 21),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$finishingTile masaya kapatıldı.',
                      style: ZyraTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    NocturnePillBadge(
                      label: 'Pot Toplamı: $potCoins Bakır',
                      dotColor: ZyraColors.primary,
                      textColor: ZyraColors.primaryBright,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Score Breakdown
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: r.$5
                          ? ZyraColors.surfaceElevated
                          : ZyraColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: r.$5
                            ? ZyraColors.primary.withValues(alpha: 0.45)
                            : ZyraColors.hairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: r.$5
                                ? ZyraColors.primary
                                : ZyraColors.surfaceElevated,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            r.$1,
                            style: ZyraTypography.dataMono.copyWith(
                              fontSize: 12,
                              color: r.$5
                                  ? ZyraColors.onPrimary
                                  : ZyraColors.onBackground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.$2,
                                style: ZyraTypography.titleMedium
                                    .copyWith(fontSize: 13),
                              ),
                              Text(
                                r.$3,
                                style: ZyraTypography.labelSmall.copyWith(
                                  fontSize: 11,
                                  color: r.$5
                                      ? ZyraColors.secondaryBright
                                      : ZyraColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          r.$4,
                          style: ZyraTypography.dataMono.copyWith(
                            color: r.$5
                                ? ZyraColors.secondaryBright
                                : ZyraColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _ReceiptLine('Açılan Per Toplamı', '$openedScore Puan'),
                    const SizedBox(height: 6),
                    _ReceiptLine('Bitiş Taşı Türü', finishingTile,
                        accent: ZyraColors.primaryBright),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              JellyButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, true);
                },
                label: 'Yeni Ele Başla (Masada Kal)',
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: ZyraColors.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              JellyButton(
                onPressed: () {
                  ShareService.shareGeneral(
                    text:
                        'Nocturne Kafe · Masa 08 (El $handNumber/4): $winnerName $openedScore puanla ($finishingTile) kazandı! ☕',
                  );
                },
                label: 'Hesap Pusulasını Paylaş',
                outlined: true,
                icon: const Icon(
                  Icons.share_outlined,
                  color: ZyraColors.onBackground,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Salona Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;

  const _ReceiptLine(this.label, this.value, {this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: ZyraTypography.bodySmall),
        const Spacer(),
        Text(
          value,
          style: ZyraTypography.dataMono.copyWith(
            color: accent ?? ZyraColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
