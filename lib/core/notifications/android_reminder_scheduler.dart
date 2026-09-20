import 'package:flutter/services.dart';

import '../models/task.dart';
import 'reminder_scheduler.dart';

class AndroidReminderScheduler implements ReminderScheduler {
  const AndroidReminderScheduler();

  static const _channel = MethodChannel('loopin/reminders');

  @override
  Future<void> schedule(Task task) async {
    final reminderAt = task.reminderAt;
    if (reminderAt == null || reminderAt.isBefore(DateTime.now().toUtc()))
      return;
    try {
      await _channel.invokeMethod<void>('schedule', <String, Object?>{
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'triggerAtMillis': reminderAt.millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      // Non-Android targets keep the reminder metadata and skip delivery.
    }
  }

  @override
  Future<void> cancel(Task task) async {
    try {
      await _channel.invokeMethod<void>('cancel', <String, Object?>{
        'id': task.id,
      });
    } on MissingPluginException {
      // Non-Android targets have no native alarm to cancel.
    }
  }
}
