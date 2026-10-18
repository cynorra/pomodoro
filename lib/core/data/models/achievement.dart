import 'package:isar/isar.dart';

part 'achievement.g.dart';

@collection
class Achievement {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String achievementId;
  
  late String nameTr;
  late String nameEn;
  late String descriptionTr;
  late String descriptionEn;
  late String iconEmoji;
  late bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.achievementId,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}
