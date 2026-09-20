import '../../../core/data/local_store.dart';
import '../../../core/models/task.dart';

class TaskRepository {
  TaskRepository(this._store);

  final LocalStore _store;

  List<Task> getAll() => _store.readTasks();

  Future<void> save(Task task) async {
    final tasks = getAll();
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      tasks.insert(0, task);
    } else {
      tasks[index] = task;
    }
    await _store.writeTasks(tasks);
  }

  Future<void> delete(String id) async {
    await _store.writeTasks(getAll().where((task) => task.id != id));
  }
}
