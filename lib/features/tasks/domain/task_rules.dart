import 'dart:convert';

const maxTasks = 30;
const maxTaskLength = 60;

class TaskItem {
  final String title;
  final bool done;
  const TaskItem(this.title, {this.done = false});

  TaskItem toggled() => TaskItem(title, done: !done);

  Map<String, dynamic> toJson() => {'t': title, 'd': done};
}

String encodeTasks(List<TaskItem> tasks) =>
    jsonEncode([for (final t in tasks) t.toJson()]);

/// Tolerant: bad or missing data gives an empty list instead of an error.
List<TaskItem> decodeTasks(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final list = jsonDecode(raw) as List;
    return [
      for (final e in list)
        if (e is Map && e['t'] is String)
          TaskItem(e['t'] as String, done: e['d'] == true),
    ];
  } catch (_) {
    return [];
  }
}

/// Adds a task unless it is empty or the list is full.
List<TaskItem> addTask(List<TaskItem> tasks, String raw) {
  var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty || tasks.length >= maxTasks) return tasks;
  if (t.length > maxTaskLength) t = t.substring(0, maxTaskLength);
  return [...tasks, TaskItem(t)];
}

/// Open tasks first (keeping order), finished ones last.
List<TaskItem> sortedTasks(List<TaskItem> tasks) =>
    [...tasks.where((t) => !t.done), ...tasks.where((t) => t.done)];
