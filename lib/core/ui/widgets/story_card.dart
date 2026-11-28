import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../zyra_theme.dart';

/// Logical size of a 9:16 story card; captured at pixelRatio 4 it is 1080x1920.
const storyCardWidth = 270.0;
const storyCardHeight = 480.0;

/// Nocturne Atelier 9:16 Instagram/WhatsApp Story share card.
class StoryCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String value;
  final String caption;
  final List<String> lines;
  final String footer;

  const StoryCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.value,
    required this.caption,
    this.lines = const [],
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: storyCardWidth,
      height: storyCardHeight,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        color: ZyraColors.background,
        border: Border.all(color: ZyraColors.hairlineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ATÖLYE KAYDI',
                  style: ZyraTypography.dataMono.copyWith(
                    fontSize: 9,
                    color: ZyraColors.textTertiary,
                    letterSpacing: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ZyraColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ZyraColors.hairlineStrong),
                ),
                child: Text(
                  '• ONAYLANDI',
                  style: ZyraTypography.dataMono.copyWith(
                    fontSize: 8,
                    color: ZyraColors.primary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: ZyraColors.divider),
          const SizedBox(height: 16),
          Text(
            title,
            style: ZyraTypography.editorialItalic.copyWith(
              fontSize: 22,
              color: ZyraColors.onBackground,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sessiz kütüphanede, tek bir lamba altında demlenen saatler.',
            style: ZyraTypography.editorialItalic.copyWith(
              fontSize: 11,
              color: ZyraColors.textSecondary,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(170, 170),
                    painter: _StoryDialPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 22,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: ZyraTypography.displayLarge.copyWith(
                          fontSize: 40,
                          color: ZyraColors.onBackground,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        caption.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: ZyraTypography.dataMono.copyWith(
                          fontSize: 9,
                          color: ZyraColors.primary,
                          letterSpacing: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (lines.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZyraColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ZyraColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final l in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        l,
                        style: ZyraTypography.dataMono.copyWith(
                          fontSize: 10,
                          color: ZyraColors.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.local_cafe_outlined,
                color: ZyraColors.primary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZyraTypography.editorialItalic.copyWith(
                    fontSize: 12,
                    color: ZyraColors.onBackground,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    for (int i = 0; i < 48; i++) {
      final a = -math.pi / 2 + (i * 2 * math.pi / 48);
      final major = i % 4 == 0;
      final paint = Paint()
        ..color = i < 12
            ? ZyraColors.primary
            : ZyraColors.onBackground.withValues(alpha: major ? 0.35 : 0.14)
        ..strokeWidth = major ? 1.5 : 1.0
        ..strokeCap = StrokeCap.round;
      final len = major ? 8.0 : 4.5;
      canvas.drawLine(
        Offset(center.dx + (r - len) * math.cos(a),
            center.dy + (r - len) * math.sin(a)),
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
