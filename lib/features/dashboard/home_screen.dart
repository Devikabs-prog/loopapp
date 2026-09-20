import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/models/task.dart';
import '../../core/widgets/animated_entrance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _HomeBody(app: app),
              _ComingSoonBody(
                icon: Icons.timer_outlined,
                title: 'Focus mode',
                message: 'Your focus sessions will live here.',
                onAction: () => setState(() => _selectedTab = 0),
              ),
              _ComingSoonBody(
                icon: Icons.auto_stories_outlined,
                title: 'Learn',
                message: 'Subjects, lessons, and quizzes are coming next.',
                onAction: () => setState(() => _selectedTab = 0),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/focus');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/learning');
            } else {
              setState(() => _selectedTab = 0);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Learn',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.app});
  final dynamic app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = app.profile?.displayName ?? 'Student';
    final firstName = name.trim().split(' ').first;
    final completed = app.tasks.length - app.pendingTasks.length;
    final progress = app.tasks.isEmpty ? 0.0 : completed / app.tasks.length;

    return RefreshIndicator(
      onRefresh: () async => app.notifyListeners(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hey, $firstName 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _ProfileButton(
                name: name,
                onSignOut: () async {
                  await app.signOut();
                  if (context.mounted)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 80),
            child: _MomentumCard(
              progress: progress,
              completed: completed,
              remaining: app.pendingTasks.length,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/calendar'),
                child: const Text('Calendar'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_task,
                  label: 'New task',
                  color: const Color(0xFFE2F3ED),
                  onTap: () => Navigator.pushNamed(context, '/add-task'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.calendar_month_outlined,
                  label: 'Plan day',
                  color: const Color(0xFFFFEFD9),
                  onTap: () => Navigator.pushNamed(context, '/calendar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${app.pendingTasks.length} remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (app.tasks.isEmpty)
            const AnimatedEntrance(
              delay: Duration(milliseconds: 220),
              child: _EmptyTasks(),
            )
          else
            ...app.tasks.asMap().entries.map(
              (entry) => AnimatedEntrance(
                delay: Duration(milliseconds: 220 + ((entry.key as int) * 45)),
                child: _TaskTile(task: entry.value),
              ),
            ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.name, required this.onSignOut});
  final String name;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => PopupMenuButton<bool>(
    onSelected: (shouldSignOut) {
      if (shouldSignOut) onSignOut();
    },
    itemBuilder: (_) => [
      const PopupMenuItem<bool>(value: true, child: Text('Sign out')),
    ],
    child: CircleAvatar(
      radius: 22,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        name.isEmpty ? 'S' : name[0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _MomentumCard extends StatelessWidget {
  const _MomentumCard({
    required this.progress,
    required this.completed,
    required this.remaining,
  });
  final double progress;
  final int completed;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [scheme.primary, const Color(0xFF247D68)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s momentum',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    completed == 0 ? 'Start your loop' : 'Nice progress!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$completed done  •  $remaining left',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 76,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 7,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                  Text(
                    '${(animatedProgress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final due = task.dueAt == null
        ? null
        : 'Due ${task.dueAt!.day}/${task.dueAt!.month}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => app.toggleTask(task),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          [
            if (task.description.isNotEmpty) task.description,
            if (due != null) due,
          ].join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => app.deleteTask(task),
        ),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: [
        Icon(
          Icons.wb_sunny_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 10),
        Text(
          'A clear desk, a fresh start',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add one small task and get your momentum going.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody({
    required this.icon,
    required this.title,
    required this.message,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: onAction,
            child: const Text('Back to home'),
          ),
        ],
      ),
    ),
  );
}
