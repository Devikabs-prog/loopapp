import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/widgets/animated_entrance.dart';
import '../../study/models/study_models.dart';
import 'flashcard_study_screen.dart';
import 'subject_detail_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addSubject(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subject name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty && context.mounted)
      await AppScope.studyOf(context).addSubject(name);
  }

  Widget build(BuildContext context) {
    final study = AppScope.studyOf(context);
    return AnimatedBuilder(
      animation: study,
      builder: (context, _) {
        final subjects = study.subjects
            .where(
              (subject) =>
                  subject.name.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
        final now = DateTime.now().toUtc();
        final cardCount = study.flashcardSets.fold<int>(
          0,
          (total, set) => total + set.cards.length,
        );
        final dueCount = study.flashcardSets.fold<int>(
          0,
          (total, set) =>
              total +
              set.cards
                  .where(
                    (card) =>
                        card.nextReviewAt == null ||
                        !card.nextReviewAt!.isAfter(now),
                  )
                  .length,
        );
        final answeredQuestions = study.attempts.fold<int>(
          0,
          (total, attempt) => total + attempt.answers.length,
        );
        final correctAnswers = study.attempts.fold<int>(
          0,
          (total, attempt) => total + attempt.score,
        );
        final accuracy = answeredQuestions == 0
            ? 0
            : (correctAnswers / answeredQuestions * 100).round();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Learn'),
            actions: [
              IconButton(
                onPressed: () => _addSubject(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addSubject(context),
            icon: const Icon(Icons.add),
            label: const Text('Subject'),
          ),
          body: study.subjects.isEmpty
              ? const _EmptyLearning()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _StudyOverview(
                      subjects: study.subjects.length,
                      notes: study.notes.length,
                      cards: cardCount,
                      due: dueCount,
                      attempts: study.attempts.length,
                      accuracy: accuracy,
                      onReview: dueCount == 0
                          ? null
                          : () {
                              final set = study.flashcardSets.firstWhere(
                                (item) => item.cards.any(
                                  (card) =>
                                      card.nextReviewAt == null ||
                                      !card.nextReviewAt!.isAfter(now),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlashcardStudyScreen(
                                    cardSet: set,
                                    dueOnly: true,
                                  ),
                                ),
                              );
                            },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search subjects',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.clear),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (subjects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No subjects match your search.'),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: .95,
                            ),
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          final lessons = study.lessons
                              .where((lesson) => lesson.subjectId == subject.id)
                              .toList();
                          return AnimatedEntrance(
                            delay: Duration(milliseconds: index * 70),
                            child: _SubjectCard(
                              subject: subject,
                              completed: lessons
                                  .where((lesson) => lesson.completed)
                                  .length,
                              total: lessons.length,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubjectDetailScreen(subject: subject),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _StudyOverview extends StatelessWidget {
  const _StudyOverview({
    required this.subjects,
    required this.notes,
    required this.cards,
    required this.due,
    required this.attempts,
    required this.accuracy,
    required this.onReview,
  });
  final int subjects;
  final int notes;
  final int cards;
  final int due;
  final int attempts;
  final int accuracy;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your study library',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('Keep notes, cards, and practice in one focused place.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _OverviewStat(label: 'Subjects', value: '$subjects'),
              _OverviewStat(label: 'Notes', value: '$notes'),
              _OverviewStat(label: 'Cards', value: '$cards'),
              _OverviewStat(label: 'Due now', value: '$due'),
              _OverviewStat(label: 'Quiz attempts', value: '$attempts'),
              _OverviewStat(label: 'Accuracy', value: '$accuracy%'),
            ],
          ),
          if (onReview != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReview,
              icon: const Icon(Icons.replay_outlined),
              label: const Text('Review due cards'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.completed,
    required this.total,
    required this.onTap,
  });
  final Subject subject;
  final int completed;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_outlined),
            ),
            const Spacer(),
            Text(
              subject.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              '$completed of $total lessons',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyLearning extends StatelessWidget {
  const _EmptyLearning();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Build your learning space',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a subject, add lessons, and turn learning into progress.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
