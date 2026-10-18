import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/services/ad_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';

class RewardedAdButton extends ConsumerWidget {
  const RewardedAdButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isReady = AdService.isRewardedAdReady;

    return Semantics(
      button: true,
      label: l10n?.watchAdForPoints ?? 'Reklam İzle +50 Puan Kazan',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isReady ? () => _watchAd(context, ref) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ZyraColors.primary.withOpacity(isReady ? 0.2 : 0.1),
                  ZyraColors.secondary.withOpacity(isReady ? 0.2 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZyraColors.primary.withOpacity(isReady ? 0.5 : 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ZyraColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: ZyraColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.watchAdForPoints ?? 'Reklam İzle',
                        style: ZyraTypography.titleMedium.copyWith(
                          color: ZyraColors.onSurface,
                        ),
                      ),
                      Text(
                        '+50 puan kazan',
                        style: ZyraTypography.labelSmall.copyWith(
                          color: ZyraColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isReady ? Icons.arrow_forward : Icons.hourglass_empty,
                  color: ZyraColors.primary.withOpacity(isReady ? 1 : 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _watchAd(BuildContext context, WidgetRef ref) async {
    final result = await AdService.showRewardedAd();

    if (!context.mounted) return;

    switch (result) {
      case RewardedAdResult.rewarded:
        ref.read(userProvider.notifier).addPoints(50);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 +50 puan kazandın!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case RewardedAdResult.notRewarded:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam tamamlanmadı'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case RewardedAdResult.notReady:
      case RewardedAdResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam şu an kullanılamıyor'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }
}
