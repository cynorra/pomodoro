import 'package:flutter/material.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../social/presentation/send_treat_sheet.dart';

/// Nocturne Atelier "Yaşayan Salon" — Bird's-eye cafe tables & barista counter.
class CafeHallTab extends StatefulWidget {
  final VoidCallback onOpenWhisper;
  final VoidCallback onOpenGames;

  const CafeHallTab({
    super.key,
    required this.onOpenWhisper,
    required this.onOpenGames,
  });

  @override
  State<CafeHallTab> createState() => _CafeHallTabState();
}

class _CafeHallTabState extends State<CafeHallTab> {
  int _selectedTableIndex = 0;

  static const _tables = [
    _CafeTableData(
      number: 'Masa 01',
      zone: 'Şömine Yanı',
      mode: 'Derin Odak · Pomodoro Döngüsü',
      occupied: 3,
      capacity: 4,
      remaining: '47 dk kaldı',
      initials: ['ED', 'AY', 'SEN'],
      isQuiet: true,
    ),
    _CafeTableData(
      number: 'Masa 02',
      zone: 'Kütüphane Köşesi',
      mode: 'Mimari Çizim & Tez',
      occupied: 2,
      capacity: 2,
      remaining: '32 dk kaldı',
      initials: ['SC', 'MT'],
      isQuiet: false,
    ),
    _CafeTableData(
      number: 'Masa 03',
      zone: 'Büyük Sedir Masası',
      mode: 'Akademik Okuma & Sessiz Akış',
      occupied: 5,
      capacity: 8,
      remaining: '54 dk kaldı',
      initials: ['DA', 'RN', 'OE', 'TL', 'FK'],
      isQuiet: true,
    ),
    _CafeTableData(
      number: 'Köşe Nook',
      zone: 'Gece Bahçesi Camı',
      mode: 'Bireysel Nitelikli Okuma',
      occupied: 1,
      capacity: 1,
      remaining: 'Yağmur dinleniyor',
      initials: ['ZG'],
      isQuiet: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _tables[_selectedTableIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        // Barista & Brewing Counter
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.coffee_maker_outlined,
                    color: ZyraColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demleme Barı & Ocak',
                      style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    'BARİSTA NÖBETTE',
                    style: ZyraTypography.dataMono.copyWith(
                      fontSize: 10,
                      color: ZyraColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final tag in ['MK', 'SL'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ZyraColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: ZyraColors.hairlineStrong),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tag,
                          style: ZyraTypography.dataMono.copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const NocturnePillBadge(
                    label: 'V60 #02 · 92°C',
                    dotColor: ZyraColors.secondary,
                    textColor: ZyraColors.secondaryBright,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Text(
              'Masa Düzeni',
              style: ZyraTypography.headlineMedium.copyWith(fontSize: 20),
            ),
            const Spacer(),
            Text(
              '15 Sandalye · 11 Dolu',
              style: ZyraTypography.dataMono.copyWith(
                fontSize: 11,
                color: ZyraColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        for (var i = 0; i < _tables.length; i++) ...[
          _TableCard(
            data: _tables[i],
            isMine: i == _selectedTableIndex,
            onSelect: () => setState(() => _selectedTableIndex = i),
          ),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 6),

        // Bottom active table quick-action bar
        GlassCard(
          elevated: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ZyraColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masadasınız: ${current.number} · ${current.zone}',
                      style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.local_cafe_outlined,
                      label: 'İkram Gönder',
                      onTap: () => showSendTreatSheet(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Sessiz Fısıltı',
                      onTap: widget.onOpenWhisper,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.casino_outlined,
                      label: 'Oyun Köşesi',
                      onTap: widget.onOpenGames,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CafeTableData {
  final String number;
  final String zone;
  final String mode;
  final int occupied;
  final int capacity;
  final String remaining;
  final List<String> initials;
  final bool isQuiet;

  const _CafeTableData({
    required this.number,
    required this.zone,
    required this.mode,
    required this.occupied,
    required this.capacity,
    required this.remaining,
    required this.initials,
    required this.isQuiet,
  });
}

class _TableCard extends StatelessWidget {
  final _CafeTableData data;
  final bool isMine;
  final VoidCallback onSelect;

  const _TableCard({
    required this.data,
    required this.isMine,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        border: Border.all(
          color: isMine
              ? ZyraColors.primary.withValues(alpha: 0.55)
              : ZyraColors.hairline,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: data.isQuiet
                        ? ZyraColors.primary
                        : ZyraColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${data.number} · ${data.zone}',
                    style: ZyraTypography.titleLarge.copyWith(fontSize: 16),
                  ),
                ),
                if (isMine)
                  const NocturnePillBadge(
                    label: 'Senin Masan',
                    textColor: ZyraColors.primaryBright,
                  )
                else
                  Text(
                    '${data.occupied}/${data.capacity} Dolu',
                    style: ZyraTypography.dataMono.copyWith(
                      fontSize: 11,
                      color: ZyraColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              data.mode,
              style: ZyraTypography.bodySmall.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final code in data.initials.take(4))
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: code == 'SEN'
                            ? ZyraColors.primary
                            : ZyraColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: ZyraColors.hairlineStrong),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        code,
                        style: ZyraTypography.dataMono.copyWith(
                          fontSize: 9,
                          color: code == 'SEN'
                              ? ZyraColors.onPrimary
                              : ZyraColors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  data.remaining,
                  style: ZyraTypography.dataMono.copyWith(
                    fontSize: 11,
                    color: ZyraColors.primaryBright,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZyraColors.hairline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: ZyraColors.primary),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZyraTypography.labelSmall.copyWith(
                fontSize: 11,
                color: ZyraColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
