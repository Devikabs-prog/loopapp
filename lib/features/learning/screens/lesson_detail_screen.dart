import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../study/models/study_models.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({required this.lesson, super.key});
  final Lesson lesson;
  @override
  Widget build(BuildContext context) {
    final study = AppScope.studyOf(context);
    return AnimatedBuilder(
      animation: study,
      builder: (context, _) {
        final currentLesson = study.lessons.firstWhere(
          (item) => item.id == lesson.id,
          orElse: () => lesson,
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lesson'),
            actions: [
              IconButton(
                tooltip: currentLesson.bookmarked
                    ? 'Remove bookmark'
                    : 'Bookmark lesson',
                onPressed: () => study.toggleLessonBookmark(currentLesson),
                icon: Icon(
                  currentLesson.bookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Set difficulty',
                icon: const Icon(Icons.tune),
                onSelected: (value) =>
                    study.setLessonDifficulty(currentLesson, value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'easy', child: Text('Easy')),
                  PopupMenuItem(value: 'medium', child: Text('Medium')),
                  PopupMenuItem(value: 'hard', child: Text('Hard')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                currentLesson.title,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.speed, size: 18),
                  label: Text('Difficulty: ${currentLesson.difficulty}'),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    currentLesson.content.isEmpty
                        ? 'Add notes to this lesson from the subject screen.'
                        : currentLesson.content,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: currentLesson.completed
                    ? null
                    : () async {
                        await study.completeLesson(currentLesson);
                        if (context.mounted) Navigator.pop(context);
                      },
                icon: const Icon(Icons.check),
                label: Text(
                  currentLesson.completed
                      ? 'Lesson completed'
                      : 'Mark as complete',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
