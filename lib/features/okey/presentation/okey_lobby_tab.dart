import 'package:flutter/material.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import 'okey_table_screen.dart';

/// Nocturne Atelier "Oyun Köşesi · Arka Salon" — Okey 101 lobby inside Cafe.
class OkeyLobbyTab extends StatelessWidget {
  const OkeyLobbyTab({super.key});

  void _openTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OkeyTableScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ZyraColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Oyun Köşesi · Arka Salon',
                      style: ZyraTypography.headlineMedium.copyWith(fontSize: 20),
                    ),
                  ),
                  const NocturnePillBadge(
                    label: 'CANLI SALON',
                    backgroundColor: ZyraColors.secondaryContainer,
                    textColor: ZyraColors.secondaryBright,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Düşük sesli strateji ve mola alanı · 101 Sessiz Mod',
                style: ZyraTypography.bodySmall,
              ),
              const SizedBox(height: 16),

              // Active Okey Table 08 preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ZyraColors.feltDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ZyraColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Okey · Masa 08',
                          style: ZyraTypography.titleMedium.copyWith(
                            color: ZyraColors.onBackground,
                          ),
                        ),
                        const Spacer(),
                        const NocturnePillBadge(
                          label: '3 / 4 Hazır',
                          dotColor: ZyraColors.primary,
                          textColor: ZyraColors.primaryBright,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SeatBadge(initials: 'SM', name: 'Selin M.', ready: true),
                        _SeatBadge(initials: 'TK', name: 'Tolga K.', ready: true),
                        _SeatBadge(initials: 'AS', name: 'Aylin S.', ready: true),
                        _SeatBadge(initials: 'SEN', name: 'Koltuk 04', ready: false),
                      ],
                    ),
                    const SizedBox(height: 18),
                    JellyButton(
                      onPressed: () => _openTable(context),
                      label: 'Masaya Otur (101 Başla)',
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: ZyraColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Locked future table (Satranç / Tavla)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ZyraColors.surfaceElevated.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ZyraColors.hairline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ZyraColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ZyraColors.hairline),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: ZyraColors.textTertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Masa 09 · Satranç / Tavla',
                            style: ZyraTypography.titleMedium.copyWith(
                              color: ZyraColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Atölye Hazırlığı · Yeni Sezon',
                            style: ZyraTypography.labelSmall.copyWith(
                              color: ZyraColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const NocturnePillBadge(label: 'Pek Yakında'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.nightlight_outlined,
                color: ZyraColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sessiz taş atımı & fısıltılı masa kuralı geçerlidir. Mola bitiminde masadan güvenle ayrılabilirsiniz.',
                  style: ZyraTypography.bodySmall.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeatBadge extends StatelessWidget {
  final String initials;
  final String name;
  final bool ready;

  const _SeatBadge({
    required this.initials,
    required this.name,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ready ? ZyraColors.surfaceElevated : ZyraColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: ready ? ZyraColors.secondary : ZyraColors.primaryBright,
              width: 1.4,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: ZyraTypography.dataMono.copyWith(
              fontSize: 11,
              color: ready ? ZyraColors.onBackground : ZyraColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: ZyraTypography.labelSmall.copyWith(
            fontSize: 10,
            color: ZyraColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
