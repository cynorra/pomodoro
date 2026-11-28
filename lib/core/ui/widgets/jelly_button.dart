import 'package:flutter/material.dart';
import '../zyra_theme.dart';

/// Nocturne Atelier pill action button.
///
/// Full-pill silhouette (`borderRadius: 9999`), Caramel `#D98E4A` fill with
/// Espresso `#14100D` text by default, subtle `scale(0.98)` press feedback,
/// and optional ghost/outlined variant.
class JellyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final Widget? icon;
  final bool outlined;

  const JellyButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.height = 52,
    this.width,
    this.icon,
    this.outlined = false,
  });

  @override
  State<JellyButton> createState() => _JellyButtonState();
}

class _JellyButtonState extends State<JellyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final bg = widget.outlined
        ? (widget.backgroundColor ?? ZyraColors.surface)
        : (widget.backgroundColor ?? ZyraColors.primary);
    final fg = widget.outlined
        ? (widget.textColor ?? ZyraColors.onBackground)
        : (widget.textColor ?? ZyraColors.onPrimary);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isEnabled ? bg : bg.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
            border: widget.outlined
                ? Border.all(color: ZyraColors.hairlineStrong, width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZyraTypography.labelLarge.copyWith(
                    color: isEnabled ? fg : fg.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
