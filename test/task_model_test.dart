import 'package:flutter_test/flutter_test.dart';
import 'package:loopapp/core/models/task.dart';

void main() {
  test('task round trips through JSON with UTC timestamps', () {
    final task = Task(
      id: 'task-1',
      title: 'Review algebra',
      description: 'Complete practice set',
      createdAt: DateTime.utc(2026, 9, 14, 10),
      updatedAt: DateTime.utc(2026, 9, 14, 10),
      dueAt: DateTime.utc(2026, 9, 15, 18),
      reminderAt: DateTime.utc(2026, 9, 15, 17),
    );

    final restored = Task.fromJson(task.toJson());
    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.dueAt, task.dueAt);
    expect(restored.reminderAt, task.reminderAt);
    expect(restored.completed, false);
  });
}
