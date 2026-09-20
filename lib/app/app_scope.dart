import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_controller.dart';
import '../core/data/local_store.dart';
import '../core/notifications/reminder_scheduler.dart';
import '../core/notifications/android_reminder_scheduler.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/calendar/data/task_repository.dart';
import '../features/study/data/study_controller.dart';
import '../features/study/data/study_repository.dart';

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required super.notifier,
    required this.study,
    required super.child,
    super.key,
  });

  final StudyController study;

  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static StudyController studyOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.study;

  static Future<AppScope> create({required Widget child}) async {
    final preferences = await SharedPreferences.getInstance();
    final store = LocalStore(preferences);
    return AppScope(
      notifier: AppController(
        auth: AuthRepository(store),
        tasks: TaskRepository(store),
        reminders: const AndroidReminderScheduler(),
      ),
      study: StudyController(StudyRepository(store)),
      child: child,
    );
  }
}
