import 'package:isar_community/isar.dart';

part 'study_session.g.dart';

@collection
class StudySession {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime date;
  
  late int durationSeconds;
  late int pointsEarned;
  late String sessionType;
  
  StudySession({
    required this.date,
    required this.durationSeconds,
    required this.pointsEarned,
    required this.sessionType,
  });
}
