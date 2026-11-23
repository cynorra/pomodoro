const maxSubjects = 12;
const maxSubjectLength = 24;

/// Trims and caps a typed subject name; empty means "not valid".
String cleanSubject(String raw) {
  final t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  return t.length > maxSubjectLength ? t.substring(0, maxSubjectLength) : t;
}

/// Adds [name] unless it is empty, a duplicate (case-insensitive) or the list is full.
List<String> addSubject(List<String> list, String name) {
  final c = cleanSubject(name);
  if (c.isEmpty || list.length >= maxSubjects) return list;
  if (list.any((e) => e.toLowerCase() == c.toLowerCase())) return list;
  return [...list, c];
}

/// Minutes per subject, biggest first. Sessions without a subject are skipped.
List<MapEntry<String, int>> minutesBySubject(
  Iterable<({String subject, int seconds})> sessions,
) {
  final totals = <String, int>{};
  for (final s in sessions) {
    if (s.subject.isEmpty) continue;
    totals[s.subject] = (totals[s.subject] ?? 0) + s.seconds;
  }
  final out = [for (final e in totals.entries) MapEntry(e.key, e.value ~/ 60)];
  out.sort((a, b) => b.value.compareTo(a.value));
  return out;
}
