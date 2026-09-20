import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/widgets/animated_entrance.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  int _minutes = 25;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = AppScope.studyOf(context).activeFocusSession;
    return Scaffold(
      appBar: AppBar(title: const Text('Focus mode')),
      body: AnimatedEntrance(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Make space to focus',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One calm session is enough to move the loop forward.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 52),
                    const SizedBox(height: 14),
                    Text(
                      '$_minutes min',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Suggested focus session'),
                    Slider(
                      value: _minutes.toDouble(),
                      min: 5,
                      max: 90,
                      divisions: 17,
                      label: '$_minutes min',
                      onChanged: (value) =>
                          setState(() => _minutes = value.round()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [5, 15, 25, 45]
                  .map(
                    (value) => ChoiceChip(
                      label: Text('$value min'),
                      selected: _minutes == value,
                      onSelected: (_) => setState(() => _minutes = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final session = await AppScope.studyOf(context)
                    .startFocus(_minutes);
                if (context.mounted)
                  Navigator.pushNamed(
                    context,
                    '/focus-session',
                    arguments: session,
                  );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                active == null ? 'Start focus session' : 'Resume focus session',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
