import '../../../l10n/generated/app_localizations.dart';
import '../domain/gift_rules.dart';

/// Name of a treat in the user's language.
String giftItemName(AppLocalizations l10n, String itemId) {
  switch (itemId) {
    case 'coffee_espresso':
      return l10n.itemEspresso;
    case 'tea_green':
      return l10n.itemGreenTea;
    case 'cake_cheese':
      return l10n.itemCheesecake;
    default:
      return '';
  }
}

/// "☕ Espresso", or a generic gift emoji for an item this version does not know.
String giftItemLabel(AppLocalizations l10n, String itemId) {
  final item = giftItemById(itemId);
  final name = giftItemName(l10n, itemId);
  return item == null ? '🎁' : '${item.emoji} $name';
}

String relativeTime(AppLocalizations l10n, DateTime time, DateTime now) {
  final d = now.difference(time);
  if (d.inMinutes < 1) return l10n.timeJustNow;
  if (d.inMinutes < 60) return l10n.timeMinutesAgo(d.inMinutes);
  if (d.inHours < 24) return l10n.timeHoursAgo(d.inHours);
  return l10n.timeDaysAgo(d.inDays);
}
