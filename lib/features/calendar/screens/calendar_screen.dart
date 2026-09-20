import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/models/task.dart';
import '../../../core/widgets/animated_entrance.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheduled = app.tasks.where((task) => task.dueAt != null).toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add-task'),
          icon: const Icon(Icons.add),
          label: const Text('Add task'),
        ),
        body: scheduled.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No scheduled tasks yet. Add a due date to see your study plan here.',
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: scheduled.length,
                itemBuilder: (context, index) => AnimatedEntrance(
                  delay: Duration(milliseconds: 80 + (index * 55)),
                  child: _CalendarTask(task: scheduled[index]),
                ),
              ),
      ),
    );
  }
}

class _CalendarTask extends StatelessWidget {
  const _CalendarTask({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final due = task.dueAt!;
    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${due.day}', style: Theme.of(context).textTheme.titleLarge),
            Text('${due.month}/${due.year}'),
          ],
        ),
        title: Text(task.title),
        subtitle: Text(
          '${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')} ${task.completed ? '• Completed' : ''}',
        ),
        trailing: Checkbox(
          value: task.completed,
          onChanged: (_) => app.toggleTask(task),
        ),
      ),
    );
  }
}
