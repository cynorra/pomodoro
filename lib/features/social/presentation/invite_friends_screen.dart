import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/referral_api.dart';
import '../domain/referral_rules.dart';
import 'social_providers.dart';

class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  ConsumerState<InviteFriendsScreen> createState() =>
      _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  final _codeController = TextEditingController();
  bool _copiedLink = false;
  bool _copiedCode = false;
  bool _redeeming = false;

  @override
  void initState() {
    super.initState();
    // Friends may have joined since the last visit; collect their rewards.
    WidgetsBinding.instance.addPostFrameCallback((_) => _collectRewards());
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _collectRewards() async {
    final friends = await claimReferralRewards(ref);
    if (friends > 0 && mounted) {
      _snack(context.l10n
          .inviteRewardEarned(friends, friends * referralReferrerBonus));
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _copy(String text, {required bool code}) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => code ? _copiedCode = true : _copiedLink = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => code ? _copiedCode = false : _copiedLink = false);
    }
  }

  Future<void> _redeem() async {
    final l10n = context.l10n;
    setState(() => _redeeming = true);
    final result =
        await ref.read(referralApiProvider).redeem(_codeController.text);
    if (!mounted) return;
    setState(() => _redeeming = false);

    switch (result) {
      case RedeemResult.success:
        await ref.read(userProvider.notifier).addPoints(referralInviteeBonus);
        ref.invalidate(referralRedeemedProvider);
        _codeController.clear();
        if (mounted) _snack(l10n.inviteRedeemed(referralInviteeBonus));
      case RedeemResult.invalid:
        _snack(l10n.inviteCodeInvalid);
      case RedeemResult.ownCode:
        _snack(l10n.inviteCodeOwn);
      case RedeemResult.notFound:
        _snack(l10n.inviteCodeNotFound);
      case RedeemResult.alreadyRedeemed:
        ref.invalidate(referralRedeemedProvider);
        _snack(l10n.inviteCodeAlready);
      case RedeemResult.notSignedIn:
        _snack(l10n.inviteSignInRequired);
      case RedeemResult.error:
        _snack(l10n.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(signedInProvider);
    final code = signedIn ? ref.watch(inviteCodeProvider).value : null;
    final inviteLink = ShareService.generateInviteLink(referralCode: code);
    final redeemed =
        signedIn && (ref.watch(referralRedeemedProvider).value ?? false);
    final shareText = code == null
        ? l10n.inviteMessage(inviteLink)
        : l10n.inviteMessageWithCode(code, inviteLink);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.inviteFriends, style: ZyraTypography.headlineMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _Header(title: l10n.inviteTitle, body: l10n.inviteBonus),
            const SizedBox(height: 24),
            if (!signedIn)
              _SignInCard(
                text: l10n.inviteSignInRequired,
                button: l10n.login,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              )
            else
              _CodeCard(
                label: l10n.inviteYourCode,
                code: code,
                copied: _copiedCode,
                onCopy: code == null ? null : () => _copy(code, code: true),
              ),
            const SizedBox(height: 16),
            _LinkRow(
              link: inviteLink,
              copied: _copiedLink,
              onCopy: () => _copy(inviteLink, code: false),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareIconButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => ShareService.shareToWhatsApp(text: shareText),
                ),
                _ShareIconButton(
                  icon: Icons.share,
                  label: l10n.shareAction,
                  color: ZyraColors.primary,
                  onTap: () => ShareService.shareGeneral(text: shareText),
                ),
              ],
            ),
            if (signedIn && !redeemed) ...[
              const SizedBox(height: 24),
              _RedeemCard(
                controller: _codeController,
                busy: _redeeming,
                onRedeem: _redeem,
              ),
            ],
            const SizedBox(height: 24),
            _HowItWorks(l10n: l10n),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String body;

  const _Header({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZyraColors.primary.withValues(alpha: 0.15),
            ZyraColors.secondary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZyraColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard_rounded,
              color: ZyraColors.primary, size: 72),
          const SizedBox(height: 16),
          Text(
            title,
            style: ZyraTypography.headlineMedium
                .copyWith(color: ZyraColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: ZyraTypography.bodyMedium.copyWith(
              color: ZyraColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  final String text;
  final String button;
  final VoidCallback onPressed;

  const _SignInCard({
    required this.text,
    required this.button,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style:
                ZyraTypography.bodyMedium.copyWith(color: ZyraColors.onSurface),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onPressed, child: Text(button)),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String label;
  final String? code;
  final bool copied;
  final VoidCallback? onCopy;

  const _CodeCard({
    required this.label,
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ZyraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZyraColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ZyraTypography.labelSmall.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    code ?? '······',
                    style: ZyraTypography.headlineMedium.copyWith(
                      color: ZyraColors.primary,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: label,
            icon: Icon(
              copied ? Icons.check_circle : Icons.copy,
              color: copied ? Colors.green : ZyraColors.primary,
            ),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String link;
  final bool copied;
  final VoidCallback onCopy;

  const _LinkRow(
      {required this.link, required this.copied, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZyraColors.onSurface.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link,
              style: ZyraTypography.bodyMedium.copyWith(
                color: ZyraColors.onSurface.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              copied ? Icons.check_circle : Icons.copy,
              color: copied ? Colors.green : ZyraColors.primary,
            ),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onRedeem;

  const _RedeemCard({
    required this.controller,
    required this.busy,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.inviteEnterCodeTitle,
            style:
                ZyraTypography.titleMedium.copyWith(color: ZyraColors.primary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 7,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 \-]')),
            ],
            decoration: InputDecoration(
              hintText: l10n.inviteCodeHint,
              counterText: '',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => busy ? null : onRedeem(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : onRedeem,
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.inviteRedeem),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  final AppLocalizations l10n;

  const _HowItWorks({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howItWorks,
            style:
                ZyraTypography.titleMedium.copyWith(color: ZyraColors.primary),
          ),
          const SizedBox(height: 12),
          _HowItWorksStep(number: '1', text: l10n.inviteStep1),
          _HowItWorksStep(number: '2', text: l10n.inviteStep2),
          _HowItWorksStep(number: '3', text: l10n.inviteStep3),
        ],
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
            style:
                ZyraTypography.labelSmall.copyWith(color: ZyraColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String text;

  const _HowItWorksStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: ZyraColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: ZyraTypography.labelLarge
                    .copyWith(color: ZyraColors.onPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: ZyraTypography.bodyMedium
                  .copyWith(color: ZyraColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
