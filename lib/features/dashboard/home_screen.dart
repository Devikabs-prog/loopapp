import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_state.dart';
import '../auth/screens/login_screen.dart';
import 'add_task_screen.dart';
import 'task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tasksKey = 'loopin_tasks';

  final List<TaskItem> _tasks = [];
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getStringList(_tasksKey) ?? [];

    final loadedTasks = storedTasks
        .map((item) => TaskItem.fromMap(jsonDecode(item)))
        .toList();

    setState(() {
      _tasks
        ..clear()
        ..addAll(loadedTasks);
      _isLoadingTasks = false;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = _tasks
        .map((task) => jsonEncode(task.toMap()))
        .toList();

    await prefs.setStringList(_tasksKey, encodedTasks);
  }

  Future<void> _openAddTaskScreen() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTaskScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _tasks.add(
          TaskItem(
            title: result['title'] ?? '',
            description: result['description'] ?? '',
          ),
        );
      });

      await _saveTasks();
    }
  }

  Future<void> _deleteTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
    });

    await _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final studyLevelText =
    AppState.studyLevel.isEmpty ? 'Not set yet' : AppState.studyLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOOPIN'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${AppState.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Study level: $studyLevelText'),
                  const SizedBox(height: 8),
                  const Text(
                    'This is the first project shell for your student productivity app. We will build tasks, focus sessions, learning, quizzes, and rewards step by step from here.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next build targets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('1. Authentication'),
                  Text('2. Profile setup'),
                  Text('3. Tasks and reminders'),
                  Text('4. Focus mode'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Open Login Screen'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _openAddTaskScreen,
            child: const Text('Add Task'),
          ),
          const SizedBox(height: 24),
          Text(
            'My Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (_isLoadingTasks)
            const Center(child: CircularProgressIndicator())
          else if (_tasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No tasks yet. Add your first task.'),
              ),
            )
          else
            ..._tasks.asMap().entries.map(
                  (entry) => Card(
                child: ListTile(
                  title: Text(entry.value.title),
                  subtitle: Text(
                    entry.value.description.isEmpty
                        ? 'No description'
                        : entry.value.description,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteTask(entry.key),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}