import 'package:flutter/material.dart';
import '../zyra_theme.dart';

class JellyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final Widget? icon;

  const JellyButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.height = 54,
    this.width,
    this.icon,
  });

  @override
  State<JellyButton> createState() => _JellyButtonState();
}

class _JellyButtonState extends State<JellyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    final bg = widget.backgroundColor ?? ZyraColors.primary;
    final fg = widget.textColor ?? Colors.black;

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
          decoration: BoxDecoration(
            color: isEnabled ? bg : bg.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: ZyraTypography.labelLarge.copyWith(
                  color: isEnabled ? fg : fg.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
