import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../quiz/screens/quiz_setup_screen.dart';
import '../../study/models/study_models.dart';
import '../data/study_file_importer.dart';
import '../data/study_resource_launcher.dart';
import 'lesson_detail_screen.dart';
import 'flashcard_match_screen.dart';
import 'flashcard_study_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({required this.subject, super.key});
  final Subject subject;

  Future<void> _addLesson(BuildContext context) async {
    final title = TextEditingController();
    final content = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Lesson title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: content,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Lesson notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && title.text.trim().isNotEmpty && context.mounted)
      await AppScope.studyOf(context).addLesson(
        subjectId: subject.id,
        title: title.text,
        content: content.text,
      );
    title.dispose();
    content.dispose();
  }

  Future<void> _addFlashcard(BuildContext context) async {
    final front = TextEditingController();
    final back = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: front,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Prompt or term'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: back,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Answer or definition',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true &&
        front.text.trim().isNotEmpty &&
        back.text.trim().isNotEmpty &&
        context.mounted) {
      await AppScope.studyOf(context)
          .addFlashcard(subject: subject, front: front.text, back: back.text);
    }
    front.dispose();
    back.dispose();
  }

  Future<void> _addNote(BuildContext context) async {
    final title = TextEditingController();
    final content = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add study notes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Note title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: content,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Paste or type your notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save notes'),
          ),
        ],
      ),
    );
    if (saved == true &&
        title.text.trim().isNotEmpty &&
        content.text.trim().isNotEmpty &&
        context.mounted) {
      await AppScope.studyOf(context).addNote(
        subjectId: subject.id,
        title: title.text,
        content: content.text,
      );
    }
    title.dispose();
    content.dispose();
  }

  Future<void> _editNote(BuildContext context, StudyNote note) async {
    final title = TextEditingController(text: note.title);
    final content = TextEditingController(text: note.content);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit study notes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Note title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: content,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Your notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (saved == true &&
        title.text.trim().isNotEmpty &&
        content.text.trim().isNotEmpty &&
        context.mounted) {
      await AppScope.studyOf(context)
          .updateNote(note: note, title: title.text, content: content.text);
    }
    title.dispose();
    content.dispose();
  }

  Future<void> _addResource(BuildContext context) async {
    final title = TextEditingController();
    final url = TextEditingController(text: 'https://');
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add study resource'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Resource name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Web link'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save link'),
          ),
        ],
      ),
    );
    final parsed = Uri.tryParse(url.text.trim());
    if (saved == true &&
        title.text.trim().isNotEmpty &&
        parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        context.mounted) {
      await AppScope.studyOf(context)
          .addResource(subjectId: subject.id, title: title.text, url: url.text);
    } else if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid http or https link.')),
      );
    }
    title.dispose();
    url.dispose();
  }

  Future<void> _importNote(BuildContext context) async {
    try {
      final imported = await StudyFileImporter().pickTextNote();
      if (imported == null || !context.mounted) return;
      final title = imported.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
      await AppScope.studyOf(context).addNote(
        subjectId: subject.id,
        title: title.trim().isEmpty ? 'Imported note' : title,
        content: imported.content,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes imported successfully.')),
        );
      }
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Could not import this file.')),
      );
    } on MissingPluginException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File import is available on Android devices.'),
        ),
      );
    }
  }

  Future<void> _showStudyModes(BuildContext context, FlashcardSet set) async {
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Choose a study mode',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('Switch modes to strengthen recall.'),
            ),
            ListTile(
              leading: const Icon(Icons.style_outlined),
              title: const Text('Learn'),
              subtitle: const Text('Reveal each card and rate your recall.'),
              onTap: () => Navigator.pop(sheetContext, 'learn'),
            ),
            ListTile(
              leading: const Icon(Icons.extension_outlined),
              title: const Text('Match'),
              subtitle: const Text(
                'Choose the answer that matches each prompt.',
              ),
              onTap: () => Navigator.pop(sheetContext, 'match'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || mode == null) return;
    final screen = mode == 'match'
        ? FlashcardMatchScreen(cardSet: set)
        : FlashcardStudyScreen(cardSet: set);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final study = AppScope.studyOf(context);
    return AnimatedBuilder(
      animation: study,
      builder: (context, _) {
        final lessons = study.lessons
            .where((lesson) => lesson.subjectId == subject.id)
            .toList();
        final matchingQuizzes = study.quizzes
            .where((quiz) => quiz.subjectId == subject.id)
            .toList();
        final hasQuiz = matchingQuizzes.isNotEmpty;
        final matchingSets = study.flashcardSets
            .where((set) => set.subjectId == subject.id)
            .toList();
        final hasFlashcards = matchingSets.any((set) => set.cards.isNotEmpty);
        final notes = study.notes
            .where((note) => note.subjectId == subject.id)
            .toList();
        final resources = study.resources
            .where((resource) => resource.subjectId == subject.id)
            .toList();
        final subjectAttempts =
            study.attempts
                .where(
                  (attempt) =>
                      matchingQuizzes.any((quiz) => quiz.id == attempt.quizId),
                )
                .toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
        final lessonWidgets = lessons
            .map(
              (lesson) => Card(
                child: ListTile(
                  leading: Icon(
                    lesson.completed
                        ? Icons.check_circle
                        : Icons.play_circle_outline,
                  ),
                  title: Text(lesson.title),
                  subtitle: Text(
                    lesson.content.isEmpty ? 'Open lesson' : lesson.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: lesson.bookmarked
                      ? const Icon(Icons.bookmark, size: 20)
                      : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonDetailScreen(lesson: lesson),
                    ),
                  ),
                ),
              ),
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(subject.name),
            actions: [
              IconButton(
                onPressed: () => _addLesson(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addLesson(context),
            icon: const Icon(Icons.add),
            label: const Text('Lesson'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${lessons.where((lesson) => lesson.completed).length}/${lessons.length} lessons complete\nSmall steps add up.',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (lessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No lessons yet. Add your first lesson above.'),
                )
              else
                ...lessonWidgets,
              const SizedBox(height: 16),
              if (notes.isNotEmpty) ...[
                Text(
                  'Study notes',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ...notes.map(
                  (note) => Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.notes_outlined),
                      title: Text(note.title),
                      subtitle: Text(
                        note.summary.isEmpty ? note.content : note.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(note.content),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _editNote(context, note),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit notes'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await study.createFlashcardsFromNote(note);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Flashcards added from these notes.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.style_outlined),
                                label: const Text('Turn notes into flashcards'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final quiz = await study.createQuizFromNote(
                                    note,
                                  );
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QuizSetupScreen(
                                          subject: subject,
                                          quizId: quiz.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.quiz_outlined),
                                label: const Text('Practice from these notes'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (subjectAttempts.isNotEmpty) ...[
                Text(
                  'Practice history',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: subjectAttempts.take(3).map((attempt) {
                      final quiz = matchingQuizzes.firstWhere(
                        (item) => item.id == attempt.quizId,
                      );
                      return ListTile(
                        leading: const Icon(Icons.insights_outlined),
                        title: Text(
                          '${attempt.score}/${quiz.questions.length} correct',
                        ),
                        subtitle: Text(
                          attempt.completedAt
                              .toLocal()
                              .toString()
                              .split('.')
                              .first,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (resources.isNotEmpty) ...[
                Text(
                  'Study resources',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ...resources.map(
                  (resource) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.link_outlined),
                      title: Text(resource.title),
                      subtitle: Text(
                        resource.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () async {
                        try {
                          await StudyResourceLauncher().open(resource.url);
                        } on PlatformException {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open this resource.'),
                              ),
                            );
                          }
                        } on MissingPluginException {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Opening links is available on Android devices.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => _addNote(context),
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Add study notes'),
              ),
              OutlinedButton.icon(
                onPressed: () => _importNote(context),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Import a text note'),
              ),
              OutlinedButton.icon(
                onPressed: () => _addResource(context),
                icon: const Icon(Icons.add_link),
                label: const Text('Add study resource'),
              ),
              const SizedBox(height: 8),
              if (lessons.isNotEmpty || notes.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    await study.ensureStarterQuiz(subject);
                    if (context.mounted)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizSetupScreen(subject: subject),
                        ),
                      );
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text(
                    hasQuiz ? 'Take practice quiz' : 'Prepare a practice quiz',
                  ),
                ),
              if (lessons.any((lesson) => lesson.content.trim().isNotEmpty) ||
                  hasFlashcards)
                OutlinedButton.icon(
                  onPressed: () async {
                    final set = hasFlashcards
                        ? matchingSets.first
                        : await study.ensureFlashcards(subject);
                    if (context.mounted && set != null)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardStudyScreen(cardSet: set),
                        ),
                      );
                  },
                  icon: const Icon(Icons.style_outlined),
                  label: const Text('Study with flashcards'),
                ),
              if (hasFlashcards)
                OutlinedButton.icon(
                  onPressed: () => _showStudyModes(context, matchingSets.first),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Choose study mode'),
                ),
              OutlinedButton.icon(
                onPressed: () => _addFlashcard(context),
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('Create a flashcard'),
              ),
            ],
          ),
        );
      },
    );
  }
}
