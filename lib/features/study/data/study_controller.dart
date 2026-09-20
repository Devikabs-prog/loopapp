import 'package:flutter/foundation.dart';

import '../models/study_models.dart';
import 'study_repository.dart';

class StudyController extends ChangeNotifier {
  StudyController(this._repository) {
    _reload();
  }
  final StudyRepository _repository;
  List<Subject> subjects = [];
  List<Lesson> lessons = [];
  List<StudyNote> notes = [];
  List<StudyResource> resources = [];
  List<FocusSession> focusSessions = [];
  List<Quiz> quizzes = [];
  List<QuizAttempt> attempts = [];
  List<FlashcardSet> flashcardSets = [];

  FocusSession? get activeFocusSession {
    final active = focusSessions.where((session) => session.active).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return active.first;
  }

  void _reload() {
    subjects = _repository.subjects();
    lessons = _repository.lessons();
    notes = _repository.notes();
    resources = _repository.resources();
    focusSessions = _repository.focusSessions();
    quizzes = _repository.quizzes();
    attempts = _repository.attempts();
    flashcardSets = _repository.flashcardSets();
  }

  Future<void> addSubject(String name) async {
    final now = DateTime.now().toUtc();
    await _repository.saveSubject(
      Subject(
        id: 'subject-${now.microsecondsSinceEpoch}',
        name: name.trim(),
        createdAt: now,
      ),
    );
    _reload();
    notifyListeners();
  }

  Future<void> addLesson({
    required String subjectId,
    required String title,
    required String content,
  }) async {
    final id = 'lesson-${DateTime.now().microsecondsSinceEpoch}';
    await _repository.saveLesson(
      Lesson(
        id: id,
        subjectId: subjectId,
        title: title.trim(),
        content: content.trim(),
      ),
    );
    _reload();
    notifyListeners();
  }

  Future<StudyNote> addNote({
    required String subjectId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now().toUtc();
    final note = StudyNote(
      id: 'note-${now.microsecondsSinceEpoch}',
      subjectId: subjectId,
      title: title.trim(),
      content: content.trim(),
      createdAt: now,
      summary: _summarize(content),
    );
    await _repository.saveNote(note);
    _reload();
    notifyListeners();
    return note;
  }

  Future<void> updateNote({
    required StudyNote note,
    required String title,
    required String content,
  }) async {
    await _repository.saveNote(
      note.copyWith(
        title: title.trim(),
        content: content.trim(),
        summary: _summarize(content),
      ),
    );
    _reload();
    notifyListeners();
  }

  Future<void> addResource({
    required String subjectId,
    required String title,
    required String url,
  }) async {
    final now = DateTime.now().toUtc();
    await _repository.saveResource(
      StudyResource(
        id: 'resource-${now.microsecondsSinceEpoch}',
        subjectId: subjectId,
        title: title.trim(),
        url: url.trim(),
        createdAt: now,
      ),
    );
    _reload();
    notifyListeners();
  }

  Future<FlashcardSet> createFlashcardsFromNote(StudyNote note) async {
    final existing = flashcardSets
        .where((set) => set.subjectId == note.subjectId)
        .toList();
    final current = existing.isEmpty
        ? FlashcardSet(
            id: 'cards-${note.subjectId}',
            subjectId: note.subjectId,
            title: 'Study cards',
            cards: const [],
          )
        : existing.first;
    final chunks = note.content
        .split(RegExp(r'(?<=[.!?])\s+|\n+'))
        .map((item) => item.trim())
        .where((item) => item.length > 12)
        .take(12)
        .toList();
    final generated = chunks.asMap().entries.map((entry) {
      final lead = entry.value.split(RegExp(r'\s+')).take(7).join(' ');
      return Flashcard(
        id: 'note-card-${note.id}-${entry.key}',
        front: 'Explain this idea: $lead…',
        back: entry.value,
      );
    });
    final cards = [
      ...current.cards,
      ...generated.where(
        (card) => !current.cards.any((item) => item.id == card.id),
      ),
    ];
    final updated = current.copyWith(cards: cards);
    await _repository.saveFlashcardSet(updated);
    _reload();
    notifyListeners();
    return updated;
  }

  Future<Quiz> createQuizFromNote(StudyNote note) async {
    final chunks = note.content
        .split(RegExp(r'(?<=[.!?])\s+|\n+'))
        .map((item) => item.trim())
        .where((item) => item.length > 12)
        .take(8)
        .toList();
    final questions = chunks.asMap().entries.map((entry) {
      final statement = entry.value;
      final options = <String>[statement];
      for (final other in chunks) {
        if (other != statement && options.length < 3) options.add(other);
      }
      final correctIndex = entry.key % options.length;
      final first = options.removeAt(0);
      options.insert(correctIndex, first);
      return QuizQuestion(
        id: 'note-question-${note.id}-${entry.key}',
        prompt: 'Which statement is supported by “${note.title}”?',
        options: options,
        correctIndex: correctIndex,
        explanation: 'This statement comes directly from your saved notes.',
      );
    }).toList();
    final quiz = Quiz(
      id: 'quiz-${note.id}',
      subjectId: note.subjectId,
      title: '${note.title} practice',
      questions: questions.isEmpty
          ? const [
              QuizQuestion(
                id: 'note-question-empty',
                prompt: 'What should you do next with these notes?',
                options: [
                  'Review and add key ideas',
                  'Ignore them',
                  'Delete them',
                ],
                correctIndex: 0,
                explanation: 'Active review helps turn notes into memory.',
              ),
            ]
          : questions,
    );
    await _repository.saveQuiz(quiz);
    _reload();
    notifyListeners();
    return quiz;
  }

  String _summarize(String value) {
    final sentences = value
        .split(RegExp(r'(?<=[.!?])\s+|\n+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(3)
        .map(
          (item) => item.length > 180 ? '${item.substring(0, 177)}...' : item,
        )
        .toList();
    return sentences.join(' ');
  }

  Future<void> completeLesson(Lesson lesson) async {
    await _repository.saveLesson(lesson.copyWith(completed: true));
    _reload();
    notifyListeners();
  }

  Future<void> toggleLessonBookmark(Lesson lesson) async {
    await _repository.saveLesson(
      lesson.copyWith(bookmarked: !lesson.bookmarked),
    );
    _reload();
    notifyListeners();
  }

  Future<void> setLessonDifficulty(Lesson lesson, String difficulty) async {
    await _repository.saveLesson(lesson.copyWith(difficulty: difficulty));
    _reload();
    notifyListeners();
  }

  Future<FocusSession> startFocus(int minutes) async {
    if (minutes < 1 || minutes > 180) {
      throw ArgumentError('Focus duration must be between 1 and 180 minutes.');
    }
    final current = activeFocusSession;
    if (current != null) return current;
    final now = DateTime.now().toUtc();
    final session = FocusSession(
      id: 'focus-${now.microsecondsSinceEpoch}',
      durationMinutes: minutes,
      startedAt: now,
    );
    await _repository.saveFocus(session);
    _reload();
    notifyListeners();
    return session;
  }

  Future<void> updateFocus(FocusSession session) async {
    await _repository.saveFocus(session);
    _reload();
    notifyListeners();
  }

  Future<void> completeFocus(FocusSession session) async {
    await _repository.saveFocus(
      session.copyWith(completedAt: DateTime.now().toUtc(), paused: false),
    );
    _reload();
    notifyListeners();
  }

  Future<void> cancelFocus(FocusSession session) async {
    await _repository.saveFocus(
      session.copyWith(cancelledAt: DateTime.now().toUtc(), paused: false),
    );
    _reload();
    notifyListeners();
  }

  Future<void> ensureStarterQuiz(Subject subject) async {
    if (quizzes.any((quiz) => quiz.subjectId == subject.id)) return;
    await _repository.saveQuiz(
      Quiz(
        id: 'quiz-${subject.id}',
        subjectId: subject.id,
        title: '${subject.name} check-in',
        questions: const [
          QuizQuestion(
            id: 'q1',
            prompt: 'What is the best way to use this quiz?',
            options: [
              'Guess quickly',
              'Recall, answer, then review',
              'Skip every question',
            ],
            correctIndex: 1,
            explanation: 'Active recall followed by review strengthens memory.',
          ),
          QuizQuestion(
            id: 'q2',
            prompt: 'What should you do after an incorrect answer?',
            options: [
              'Review the explanation',
              'Delete the result',
              'Start over immediately',
            ],
            correctIndex: 0,
            explanation: 'Explanations turn mistakes into useful feedback.',
          ),
        ],
      ),
    );
    _reload();
    notifyListeners();
  }

  Future<FlashcardSet?> ensureFlashcards(Subject subject) async {
    final existing = flashcardSets
        .where((set) => set.subjectId == subject.id)
        .toList();
    if (existing.isNotEmpty) return existing.first;
    final subjectLessons = lessons
        .where(
          (lesson) =>
              lesson.subjectId == subject.id &&
              lesson.content.trim().isNotEmpty,
        )
        .toList();
    if (subjectLessons.isEmpty) return null;
    final set = FlashcardSet(
      id: 'cards-${subject.id}',
      subjectId: subject.id,
      title: '${subject.name} Learn set',
      cards: subjectLessons
          .asMap()
          .entries
          .map(
            (entry) => Flashcard(
              id: 'card-${entry.key}',
              front: entry.value.title,
              back: entry.value.content,
            ),
          )
          .toList(),
    );
    await _repository.saveFlashcardSet(set);
    _reload();
    notifyListeners();
    return set;
  }

  Future<FlashcardSet> addFlashcard({
    required Subject subject,
    required String front,
    required String back,
  }) async {
    final existing = flashcardSets
        .where((set) => set.subjectId == subject.id)
        .toList();
    final current = existing.isEmpty
        ? FlashcardSet(
            id: 'cards-${subject.id}',
            subjectId: subject.id,
            title: '${subject.name} Learn set',
            cards: const [],
          )
        : existing.first;
    final card = Flashcard(
      id: 'card-${DateTime.now().microsecondsSinceEpoch}',
      front: front.trim(),
      back: back.trim(),
    );
    final updated = FlashcardSet(
      id: current.id,
      subjectId: current.subjectId,
      title: current.title,
      cards: [...current.cards, card],
      lastStudiedAt: current.lastStudiedAt,
    );
    await _repository.saveFlashcardSet(updated);
    _reload();
    notifyListeners();
    return updated;
  }

  Future<void> markFlashcardsStudied(FlashcardSet set) async {
    await _repository.saveFlashcardSet(
      set.copyWith(lastStudiedAt: DateTime.now().toUtc()),
    );
    _reload();
    notifyListeners();
  }

  Future<void> reviewFlashcard({
    required FlashcardSet set,
    required int index,
    required bool remembered,
  }) async {
    if (index < 0 || index >= set.cards.length) return;
    await reviewFlashcardById(
      set: set,
      cardId: set.cards[index].id,
      remembered: remembered,
    );
  }

  Future<void> reviewFlashcardById({
    required FlashcardSet set,
    required String cardId,
    required bool remembered,
  }) async {
    final index = set.cards.indexWhere((card) => card.id == cardId);
    if (index == -1) return;
    final card = set.cards[index];
    final reviewCount = remembered ? card.reviewCount + 1 : 0;
    final intervalDays = remembered ? reviewCount * 2 : 0;
    final updatedCard = card.copyWith(
      reviewCount: reviewCount,
      nextReviewAt: DateTime.now().toUtc().add(Duration(days: intervalDays)),
    );
    final updatedCards = [...set.cards]..[index] = updatedCard;
    await _repository.saveFlashcardSet(
      set.copyWith(cards: updatedCards, lastStudiedAt: DateTime.now().toUtc()),
    );
    _reload();
    notifyListeners();
  }

  Future<QuizAttempt> submitQuiz(Quiz quiz, List<int> answers) async {
    final normalizedAnswers = List<int>.generate(
      quiz.questions.length,
      (index) => index < answers.length ? answers[index] : -1,
    );
    final score = quiz.questions
        .asMap()
        .entries
        .where(
          (entry) => entry.value.correctIndex == normalizedAnswers[entry.key],
        )
        .length;
    final now = DateTime.now().toUtc();
    final attempt = QuizAttempt(
      id: 'attempt-${now.microsecondsSinceEpoch}',
      quizId: quiz.id,
      answers: normalizedAnswers,
      score: score,
      completedAt: now,
    );
    await _repository.saveAttempt(attempt);
    _reload();
    notifyListeners();
    return attempt;
  }
}
