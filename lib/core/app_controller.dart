import 'package:flutter/foundation.dart';

import 'models/task.dart';
import 'models/user_profile.dart';
import 'notifications/reminder_scheduler.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/calendar/data/task_repository.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AuthRepository auth,
    required TaskRepository tasks,
    ReminderScheduler? reminders,
  }) : _auth = auth,
       _tasksRepository = tasks,
       _reminders = reminders ?? const NoopReminderScheduler() {
    _profile = auth.currentUser;
    _tasks = tasks.getAll();
  }

  final AuthRepository _auth;
  final TaskRepository _tasksRepository;
  final ReminderScheduler _reminders;
  UserProfile? _profile;
  List<Task> _tasks = [];
  bool isBusy = false;
  String? errorMessage;

  UserProfile? get profile => _profile;
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isSignedIn => _profile != null;
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.completed).toList();

  Future<void> signIn(String email, String password) => _run(() async {
    _profile = await _auth.signIn(email: email, password: password);
  });

  Future<void> signUp(String email, String password) => _run(() async {
    _profile = await _auth.signUp(email: email, password: password);
  });

  Future<void> saveProfile({
    required String displayName,
    required String studyLevel,
  }) => _run(() async {
    final current = _profile;
    if (current == null) throw StateError('Sign in before editing a profile.');
    _profile = await _auth.saveProfile(
      current.copyWith(
        displayName: displayName.trim().isEmpty
            ? 'Student'
            : displayName.trim(),
        studyLevel: studyLevel.trim(),
      ),
    );
  });

  Future<void> signOut() => _run(() async {
    await _auth.signOut();
    _profile = null;
  });

  Future<void> saveTask({
    required String title,
    required String description,
    DateTime? dueAt,
    DateTime? reminderAt,
  }) => _run(() async {
    final now = DateTime.now().toUtc();
    final task = Task(
      id: 'task-${now.microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
      dueAt: dueAt,
      reminderAt: reminderAt,
    );
    await _tasksRepository.save(task);
    if (task.reminderAt != null) await _reminders.schedule(task);
    _tasks = _tasksRepository.getAll();
  });

  Future<void> toggleTask(Task task) => _run(() async {
    final updated = task.copyWith(completed: !task.completed);
    await _tasksRepository.save(updated);
    if (updated.completed || updated.reminderAt == null) {
      await _reminders.cancel(updated);
    } else {
      await _reminders.schedule(updated);
    }
    _tasks = _tasksRepository.getAll();
  });

  Future<void> deleteTask(Task task) => _run(() async {
    await _tasksRepository.delete(task.id);
    await _reminders.cancel(task);
    _tasks = _tasksRepository.getAll();
  });

  Future<void> _run(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on Object catch (error) {
      errorMessage = error is FormatException
          ? error.message
          : 'Something went wrong. Please try again.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
