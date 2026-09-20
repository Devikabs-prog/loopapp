import '../models/task.dart';

/// Platform-neutral seam for local reminder delivery.
///
/// The current project keeps reminder metadata and exposes this contract. The
/// Android implementation can later be backed by flutter_local_notifications
/// without changing task screens or repositories.
abstract interface class ReminderScheduler {
  Future<void> schedule(Task task);
  Future<void> cancel(Task task);
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<void> schedule(Task task) async {}

  @override
  Future<void> cancel(Task task) async {}
}
