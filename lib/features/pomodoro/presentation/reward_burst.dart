import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/services/sfx_service.dart';
import '../../../core/ui/zyra_theme.dart';

/// Celebrates a finished focus session: the finish chime, a coin ping, a light
/// haptic tap and a short "+N" burst with sparkles over the current screen.
void showRewardBurst(
  BuildContext context, {
  required int points,
  String? boostLabel,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  HapticFeedback.mediumImpact();
  SfxService.play(Sfx.complete);
  Future.delayed(const Duration(milliseconds: 650), () {
    SfxService.play(Sfx.coin);
    HapticFeedback.lightImpact();
  });

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _RewardBurst(
      points: points,
      boostLabel: boostLabel,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _RewardBurst extends StatefulWidget {
  const _RewardBurst({
    required this.points,
    required this.onDone,
    this.boostLabel,
  });

  final int points;
  final String? boostLabel;
  final VoidCallback onDone;

  @override
  State<_RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<_RewardBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            // pop in (0-0.2), hold, fade out (0.75-1)
            final scale = t < 0.2
                ? Curves.easeOutBack.transform(t / 0.2)
                : 1.0 + 0.04 * math.sin((t - 0.2) * 12);
            final opacity = t > 0.75 ? (1 - (t - 0.75) / 0.25) : 1.0;
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: _SparklePainter(progress: t),
                  ),
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 18),
                      decoration: BoxDecoration(
                        color: ZyraColors.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ZyraColors.primary.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ZyraColors.primary.withValues(alpha: 0.35),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: ZyraColors.primary, size: 40),
                              const SizedBox(width: 8),
                              Text(
                                '+${widget.points}',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: ZyraColors.primary,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          if (widget.boostLabel != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.boostLabel!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    ZyraColors.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Little golden sparkles flying out from the centre and falling slightly.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress});

  final double progress;
  static const _count = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final rnd = math.Random(7); // fixed seed: same pattern every time
    final p = Curves.easeOutCubic.transform((progress / 0.85).clamp(0.0, 1.0));
    for (var i = 0; i < _count; i++) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final speed = 90 + rnd.nextDouble() * 170;
      final radius = 2.5 + rnd.nextDouble() * 3.5;
      final gravity = 70 * p * p;
      final pos = centre +
          Offset(math.cos(angle) * speed * p,
              math.sin(angle) * speed * p + gravity);
      final fade = (1 - p).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = (i.isEven ? ZyraColors.primary : Colors.white)
            .withValues(alpha: 0.9 * fade);
      canvas.drawCircle(pos, radius * (1 - 0.4 * p), paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
