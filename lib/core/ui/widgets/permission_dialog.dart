import 'package:flutter/material.dart';
import '../zyra_theme.dart';
import 'jelly_button.dart';
import '../../../l10n/l10n_extension.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onAllow;
  final VoidCallback? onDeny;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onAllow,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZyraColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: ZyraColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: ZyraTypography.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: ZyraTypography.bodyMedium.copyWith(
                color: ZyraColors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            JellyButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAllow();
              },
              label: context.l10n.allow,
            ),
            if (onDeny != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDeny!();
                },
                child: Text(
                  'Daha Sonra',
                  style: TextStyle(
                    color: ZyraColors.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
