import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/widgets/animated_entrance.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueAt;
  DateTime? _reminderAt;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool reminder}) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: (reminder ? _reminderAt : _dueAt) ?? DateTime.now(),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (!mounted || time == null) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
    setState(() => reminder ? _reminderAt = value : _dueAt = value);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a task title first.')));
      return;
    }
    if (_reminderAt != null && _reminderAt!.isBefore(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a reminder time in the future.')),
      );
      return;
    }
    final app = AppScope.of(context);
    await app.saveTask(
      title: _titleController.text,
      description: _descriptionController.text,
      dueAt: _dueAt,
      reminderAt: _reminderAt,
    );
    if (!mounted) return;
    if (app.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(app.errorMessage!)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add task')),
    body: AnimatedEntrance(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Create a study task',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _pickDate(reminder: false),
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _dueAt == null
                  ? 'Set due date'
                  : 'Due ${_dueAt!.day}/${_dueAt!.month}',
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickDate(reminder: true),
            icon: const Icon(Icons.notifications_none),
            label: Text(
              _reminderAt == null
                  ? 'Set reminder'
                  : 'Reminder ${_reminderAt!.day}/${_reminderAt!.month}',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: AppScope.of(context).isBusy ? null : _save,
            child: const Text('Save task'),
          ),
        ],
      ),
    ),
  );
}
