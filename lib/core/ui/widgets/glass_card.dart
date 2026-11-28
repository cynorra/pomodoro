import 'package:flutter/material.dart';
import '../zyra_theme.dart';

/// Nocturne Atelier surface card.
///
/// Uses pure tonal elevation (`#1D1814` or elevated `#261F19`) and a 1px crema
/// hairline stroke (`rgba(242, 232, 216, 0.08)`), replacing frosted blur and
/// drop shadows. Keeps the `GlassCard` class name & signature so existing
/// screens adopt the new design language seamlessly.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 0,
    this.padding,
    this.color,
    this.border,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        (elevated ? ZyraColors.surfaceElevated : ZyraColors.surface);
    final stroke = border ??
        Border.all(
          color: elevated ? ZyraColors.hairlineStrong : ZyraColors.hairline,
          width: 1,
        );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: stroke,
      ),
      child: child,
    );
  }
}

/// Static warm radial tungsten lamp glow behind hero elements (timer, milestones).
class NocturneLampGlow extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color glowColor;

  const NocturneLampGlow({
    super.key,
    required this.child,
    this.radius = 0.72,
    this.glowColor = const Color(0x16D98E4A),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: radius,
          colors: [
            glowColor,
            const Color(0x0014100D),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Editorial pill metadata badge (height 24, JetBrains Mono 11px).
class NocturnePillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? dotColor;
  final IconData? icon;

  const NocturnePillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.dotColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? ZyraColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ZyraColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? ZyraColors.textSecondary),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZyraTypography.dataMono.copyWith(
                fontSize: 11,
                color: textColor ?? ZyraColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
