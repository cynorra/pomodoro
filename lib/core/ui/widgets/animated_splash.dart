import 'package:flutter/material.dart';
import '../zyra_theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../responsive.dart';

class AnimatedSplashOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedSplashOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<AnimatedSplashOverlay> createState() => _AnimatedSplashOverlayState();
}

class _AnimatedSplashOverlayState extends State<AnimatedSplashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: context.scaled(100),
                      height: context.scaled(100),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [ZyraColors.primary, ZyraColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ZyraColors.primary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '☕',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Study Cafe',
                      style: ZyraTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.splashTagline,
                      style: ZyraTypography.bodyMedium.copyWith(
                        color: ZyraColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
