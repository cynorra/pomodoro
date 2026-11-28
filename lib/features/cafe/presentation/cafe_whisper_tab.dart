import 'package:flutter/material.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';

/// Nocturne Atelier "Fısıltı" — Quiet cafe lounge whisper feed.
class CafeWhisperTab extends StatefulWidget {
  const CafeWhisperTab({super.key});

  @override
  State<CafeWhisperTab> createState() => _CafeWhisperTabState();
}

class _CafeWhisperTabState extends State<CafeWhisperTab> {
  final _controller = TextEditingController();
  final List<_WhisperEntry> _messages = [
    const _WhisperEntry(
      initials: 'TK',
      author: 'Tolga K.',
      seat: 'Masa 07',
      time: '01:34',
      text:
          'Kütüphane arkasındaki döküm masa lambası inanılmaz bir odak alanı yarattı. Saatlerdir tek bir çizim üzerine çalışıyorum.',
    ),
    const _WhisperEntry(
      initials: 'DL',
      author: 'Defne L.',
      seat: 'Bar Taburesi',
      time: '01:38',
      text:
          'Bugünkü V60 Etiyopya kavrumu son dönemin en dengeli profili. Bergamot notaları gece sessizliğine çok yakışmış.',
    ),
    const _WhisperEntry(
      initials: 'MA',
      author: 'Mert A.',
      seat: 'Köşe Masa',
      time: '01:41',
      text:
          'Arka plandaki yağmur ve şömine sesi mimari eskiz yaparken zihni inanılmaz sakinleştiriyor. Herkese verimli geceler.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    setState(() {
      _messages.add(
        _WhisperEntry(
          initials: 'SEN',
          author: 'Sen',
          seat: 'Masa 01',
          time: '$hh:$mm',
          text: text,
          isMine: true,
        ),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: NocturnePillBadge(
            label: 'Gece yarısı sessizlik protokolü devrede',
            icon: Icons.nightlight_round,
            textColor: ZyraColors.textSecondary,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const Divider(
              height: 22,
              color: ZyraColors.divider,
            ),
            itemBuilder: (context, index) {
              final m = _messages[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: m.isMine
                          ? ZyraColors.primary
                          : ZyraColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: ZyraColors.hairlineStrong),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      m.initials,
                      style: ZyraTypography.dataMono.copyWith(
                        fontSize: 10,
                        color: m.isMine
                            ? ZyraColors.onPrimary
                            : ZyraColors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              m.author,
                              style: ZyraTypography.titleMedium.copyWith(
                                fontSize: 13,
                                color: m.isMine
                                    ? ZyraColors.primaryBright
                                    : ZyraColors.onBackground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              m.seat,
                              style: ZyraTypography.labelSmall.copyWith(
                                color: ZyraColors.textTertiary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              m.time,
                              style: ZyraTypography.dataMono.copyWith(
                                fontSize: 11,
                                color: ZyraColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.text,
                          style: ZyraTypography.bodyMedium.copyWith(
                            fontSize: 13.5,
                            color: ZyraColors.onBackground.withValues(alpha: 0.88),
                            height: 1.48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: ZyraColors.surfaceDim,
            border: Border(top: BorderSide(color: ZyraColors.hairline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: ZyraTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Sessizce bir fısıltı bırak...',
                    isDense: true,
                    filled: true,
                    fillColor: ZyraColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ZyraColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ZyraColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ZyraColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: ZyraColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: ZyraColors.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WhisperEntry {
  final String initials;
  final String author;
  final String seat;
  final String time;
  final String text;
  final bool isMine;

  const _WhisperEntry({
    required this.initials,
    required this.author,
    required this.seat,
    required this.time,
    required this.text,
    this.isMine = false,
  });
}
