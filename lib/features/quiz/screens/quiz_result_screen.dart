import 'package:flutter/material.dart';

import '../../study/models/study_models.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    required this.attempt,
    required this.quiz,
    super.key,
  });
  final QuizAttempt attempt;
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final percentage = (attempt.score / quiz.questions.length * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz result')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 54,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '$percentage%',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${attempt.score} of ${quiz.questions.length} correct',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 26),
          ...quiz.questions.asMap().entries.map((entry) {
            final correct =
                attempt.answers[entry.key] == entry.value.correctIndex;
            return Card(
              child: ListTile(
                leading: Icon(
                  correct ? Icons.check_circle : Icons.info_outline,
                  color: correct ? Colors.green : Colors.orange,
                ),
                title: Text(entry.value.prompt),
                subtitle: Text(entry.value.explanation),
              ),
            );
          }),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/learning',
              (_) => false,
            ),
            child: const Text('Back to learning'),
          ),
        ],
      ),
    );
  }
}
