import '../../../core/data/local_store.dart';
import '../models/study_models.dart';

class StudyRepository {
  StudyRepository(this._store);
  final LocalStore _store;
  static const _subjectsKey = 'loopin.study.subjects.v1';
  static const _lessonsKey = 'loopin.study.lessons.v1';
  static const _notesKey = 'loopin.study.notes.v1';
  static const _resourcesKey = 'loopin.study.resources.v1';
  static const _focusKey = 'loopin.study.focus.v1';
  static const _quizzesKey = 'loopin.study.quizzes.v1';
  static const _attemptsKey = 'loopin.study.attempts.v1';
  static const _flashcardSetsKey = 'loopin.study.flashcards.v1';

  List<Subject> subjects() =>
      _store.readRecords(_subjectsKey).map(Subject.fromJson).toList();
  List<Lesson> lessons() =>
      _store.readRecords(_lessonsKey).map(Lesson.fromJson).toList();
  List<StudyNote> notes() =>
      _store.readRecords(_notesKey).map(StudyNote.fromJson).toList();
  List<StudyResource> resources() =>
      _store.readRecords(_resourcesKey).map(StudyResource.fromJson).toList();
  List<FocusSession> focusSessions() =>
      _store.readRecords(_focusKey).map(FocusSession.fromJson).toList();
  List<Quiz> quizzes() =>
      _store.readRecords(_quizzesKey).map(Quiz.fromJson).toList();
  List<QuizAttempt> attempts() =>
      _store.readRecords(_attemptsKey).map(QuizAttempt.fromJson).toList();
  List<FlashcardSet> flashcardSets() =>
      _store.readRecords(_flashcardSetsKey).map(FlashcardSet.fromJson).toList();

  Future<void> saveSubject(Subject value) => _save(
    _subjectsKey,
    subjects(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveLesson(Lesson value) => _save(
    _lessonsKey,
    lessons(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveNote(StudyNote value) => _save(
    _notesKey,
    notes(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveResource(StudyResource value) => _save(
    _resourcesKey,
    resources(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveFocus(FocusSession value) => _save(
    _focusKey,
    focusSessions(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveQuiz(Quiz value) => _save(
    _quizzesKey,
    quizzes(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveAttempt(QuizAttempt value) => _save(
    _attemptsKey,
    attempts(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );
  Future<void> saveFlashcardSet(FlashcardSet value) => _save(
    _flashcardSetsKey,
    flashcardSets(),
    value,
    (item) => item.id,
    (item) => item.toJson(),
  );

  Future<void> _save<T>(
    String key,
    List<T> values,
    T value,
    String Function(T) id,
    Map<String, dynamic> Function(T) json,
  ) async {
    final index = values.indexWhere((item) => id(item) == id(value));
    if (index == -1)
      values.add(value);
    else
      values[index] = value;
    await _store.writeRecords(key, values.map(json));
  }
}
