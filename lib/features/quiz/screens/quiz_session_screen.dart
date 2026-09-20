import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../study/models/study_models.dart';
import 'quiz_result_screen.dart';

class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({
    required this.subject,
    this.quizId,
    this.durationMinutes = 0,
    super.key,
  });
  final Subject subject;
  final String? quizId;
  final int durationMinutes;
  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  final List<int> _answers = [];
  late int _remainingSeconds;
  Timer? _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _submitted) return;
        if (_remainingSeconds <= 1) {
          _timer?.cancel();
          _submit();
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _answer(int selected) async {
    if (_submitted) return;
    final study = AppScope.studyOf(context);
    final quizzes = study.quizzes
        .where((quiz) => quiz.subjectId == widget.subject.id)
        .toList();
    if (quizzes.isEmpty) return;
    final quiz = widget.quizId == null
        ? quizzes.first
        : quizzes.firstWhere(
            (item) => item.id == widget.quizId,
            orElse: () => quizzes.first,
          );
    _answers.add(selected);
    if (_index < quiz.questions.length - 1) {
      setState(() => _index++);
    } else {
      await _submit(quiz: quiz);
    }
  }

  Future<void> _submit({Quiz? quiz}) async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final study = AppScope.studyOf(context);
    final selectedQuizzes = study.quizzes
        .where((item) => item.subjectId == widget.subject.id)
        .toList();
    if (selectedQuizzes.isEmpty) return;
    final activeQuiz =
        quiz ??
        (widget.quizId == null
            ? selectedQuizzes.first
            : selectedQuizzes.firstWhere(
                (item) => item.id == widget.quizId,
                orElse: () => selectedQuizzes.first,
              ));
    final attempt = await study.submitQuiz(activeQuiz, _answers);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(attempt: attempt, quiz: activeQuiz),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final study = AppScope.studyOf(context);
    final quizzes = study.quizzes
        .where((quiz) => quiz.subjectId == widget.subject.id)
        .toList();
    if (quizzes.isEmpty)
      return const Scaffold(body: Center(child: Text('Quiz unavailable')));
    final quiz = widget.quizId == null
        ? quizzes.first
        : quizzes.firstWhere(
            (item) => item.id == widget.quizId,
            orElse: () => quizzes.first,
          );
    final question = quiz.questions[_index];
    final timerLabel = _remainingSeconds == 0
        ? null
        : '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_index + 1}/${quiz.questions.length}'),
        actions: [
          if (timerLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  timerLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / quiz.questions.length,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 28),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          ...question.options.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnswerTile(
                index: entry.key,
                label: entry.value,
                onTap: () => _answer(entry.key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.index,
    required this.label,
    required this.onTap,
  });
  final int index;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            child: Text(String.fromCharCode(65 + index)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
