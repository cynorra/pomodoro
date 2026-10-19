import 'dart:ui';
import 'package:flutter/material.dart';
import '../zyra_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 12,
    this.padding,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? ZyraColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
