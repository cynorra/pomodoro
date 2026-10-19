import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/services/share_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';

class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  ConsumerState<InviteFriendsScreen> createState() =>
      _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inviteLink = ShareService.generateInviteLink();

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.inviteFriends,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ZyraColors.primary.withOpacity(0.15),
                    ZyraColors.secondary.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ZyraColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    color: ZyraColors.primary,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.inviteTitle,
                    style: ZyraTypography.headlineMedium.copyWith(
                      color: ZyraColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.inviteBonus,
                    style: ZyraTypography.bodyMedium.copyWith(
                      color: ZyraColors.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZyraColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ZyraColors.onSurface.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      inviteLink,
                      style: ZyraTypography.bodyMedium.copyWith(
                        color: ZyraColors.onSurface.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _copied ? Icons.check_circle : Icons.copy,
                      color: _copied ? Colors.green : ZyraColors.primary,
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: inviteLink));
                      setState(() => _copied = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _copied = false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareIconButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    ShareService.shareToWhatsApp(
                      text: context.l10n.inviteMessage(inviteLink),
                    );
                  },
                ),
                _ShareIconButton(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  color: const Color(0xFFE4405F),
                  onTap: () {
                    ShareService.shareGeneral(
                      text: context.l10n.inviteMessage(inviteLink),
                    );
                  },
                ),
                _ShareIconButton(
                  icon: Icons.share,
                  label: context.l10n.other,
                  color: ZyraColors.primary,
                  onTap: () {
                    ShareService.shareGeneral(
                      text: context.l10n.inviteMessage(inviteLink),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ZyraColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.howItWorks,
                    style: ZyraTypography.titleMedium.copyWith(
                      color: ZyraColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HowItWorksStep(
                    number: '1',
                    text: context.l10n.inviteStep1,
                  ),
                  _HowItWorksStep(
                    number: '2',
                    text: context.l10n.inviteStep2,
                  ),
                  _HowItWorksStep(
                    number: '3',
                    text: context.l10n.inviteStep3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShareIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: ZyraTypography.labelSmall.copyWith(
              color: ZyraColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String text;

  const _HowItWorksStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ZyraColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: ZyraTypography.labelLarge.copyWith(
                  color: ZyraColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: ZyraTypography.bodyMedium.copyWith(
                color: ZyraColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
