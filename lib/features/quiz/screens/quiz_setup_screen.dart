import 'package:flutter/material.dart';

import '../../study/models/study_models.dart';
import 'quiz_session_screen.dart';

class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({required this.subject, this.quizId, super.key});
  final Subject subject;
  final String? quizId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice quiz')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 68,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              '${subject.name} check-in',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a timer, then use active recall to practice your notes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: () async {
                final minutes = await showDialog<int>(
                  context: context,
                  builder: (dialogContext) => SimpleDialog(
                    title: const Text('Practice test timer'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialogContext, 0),
                        child: const Text('No timer'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialogContext, 5),
                        child: const Text('5 minutes'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(dialogContext, 10),
                        child: const Text('10 minutes'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted || minutes == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizSessionScreen(
                      subject: subject,
                      quizId: quizId,
                      durationMinutes: minutes,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start quiz'),
            ),
          ],
        ),
      ),
    ),
  );
}
