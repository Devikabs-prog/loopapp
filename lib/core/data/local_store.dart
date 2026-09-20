import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/user_profile.dart';

class LocalStore {
  LocalStore(this._preferences);

  final SharedPreferences _preferences;

  static const _tasksKey = 'loopin.tasks.v1';
  static const _profileKey = 'loopin.profile.v1';
  static const _sessionKey = 'loopin.session.v1';

  List<Task> readTasks() {
    final values = _preferences.getStringList(_tasksKey) ?? const [];
    return values
        .map(
          (value) => Task.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> writeTasks(Iterable<Task> tasks) => _preferences.setStringList(
    _tasksKey,
    tasks.map((task) => jsonEncode(task.toJson())).toList(),
  );

  UserProfile? readProfile() {
    final value = _preferences.getString(_profileKey);
    if (value == null) return null;
    return UserProfile.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> writeProfile(UserProfile profile) =>
      _preferences.setString(_profileKey, jsonEncode(profile.toJson()));

  String? readSessionId() => _preferences.getString(_sessionKey);

  Future<void> writeSession(String id) =>
      _preferences.setString(_sessionKey, id);

  Future<void> clearSession() => _preferences.remove(_sessionKey);

  List<Map<String, dynamic>> readRecords(String key) {
    final values = _preferences.getStringList(key) ?? const [];
    return values
        .map((value) => jsonDecode(value) as Map<String, dynamic>)
        .toList();
  }

  Future<void> writeRecords(
    String key,
    Iterable<Map<String, dynamic>> records,
  ) => _preferences.setStringList(key, records.map(jsonEncode).toList());
}
