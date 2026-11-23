import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/subject_rules.dart';

class SubjectState {
  final List<String> subjects;
  final String selected;
  const SubjectState({this.subjects = const [], this.selected = ''});
}

final subjectProvider =
    NotifierProvider<SubjectNotifier, SubjectState>(SubjectNotifier.new);

class SubjectNotifier extends Notifier<SubjectState> {
  static const _storage = FlutterSecureStorage();
  static const _listKey = 'subjects';
  static const _selectedKey = 'subject_selected';

  @override
  SubjectState build() {
    _load();
    return const SubjectState();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _listKey);
      final sel = await _storage.read(key: _selectedKey) ?? '';
      final list = raw == null
          ? <String>[]
          : (jsonDecode(raw) as List).map((e) => '$e').toList();
      state = SubjectState(subjects: list, selected: sel);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _storage.write(key: _listKey, value: jsonEncode(state.subjects));
      await _storage.write(key: _selectedKey, value: state.selected);
    } catch (_) {}
  }

  Future<void> select(String name) async {
    state = SubjectState(subjects: state.subjects, selected: name);
    await _save();
  }

  Future<void> add(String name) async {
    final list = addSubject(state.subjects, name);
    final c = cleanSubject(name);
    final match = list.firstWhere(
      (e) => e.toLowerCase() == c.toLowerCase(),
      orElse: () => '',
    );
    state = SubjectState(subjects: list, selected: match);
    await _save();
  }

  Future<void> remove(String name) async {
    state = SubjectState(
      subjects: state.subjects.where((e) => e != name).toList(),
      selected: state.selected == name ? '' : state.selected,
    );
    await _save();
  }
}
