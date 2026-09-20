class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  final String id;
  final String name;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Untitled subject',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    this.completed = false,
    this.bookmarked = false,
    this.difficulty = 'medium',
  });
  final String id;
  final String subjectId;
  final String title;
  final String content;
  final bool completed;
  final bool bookmarked;
  final String difficulty;

  Lesson copyWith({bool? completed, bool? bookmarked, String? difficulty}) =>
      Lesson(
        id: id,
        subjectId: subjectId,
        title: title,
        content: content,
        completed: completed ?? this.completed,
        bookmarked: bookmarked ?? this.bookmarked,
        difficulty: difficulty ?? this.difficulty,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'title': title,
    'content': content,
    'completed': completed,
    'bookmarked': bookmarked,
    'difficulty': difficulty,
  };
  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String? ?? 'Untitled lesson',
    content: json['content'] as String? ?? '',
    completed: json['completed'] as bool? ?? false,
    bookmarked: json['bookmarked'] as bool? ?? false,
    difficulty: json['difficulty'] as String? ?? 'medium',
  );
}

class StudyNote {
  const StudyNote({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.summary = '',
  });
  final String id;
  final String subjectId;
  final String title;
  final String content;
  final DateTime createdAt;
  final String summary;

  StudyNote copyWith({String? title, String? content, String? summary}) =>
      StudyNote(
        id: id,
        subjectId: subjectId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        summary: summary ?? this.summary,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'summary': summary,
  };

  factory StudyNote.fromJson(Map<String, dynamic> json) => StudyNote(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String? ?? 'Untitled note',
    content: json['content'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    summary: json['summary'] as String? ?? '',
  );
}

class StudyResource {
  const StudyResource({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.url,
    required this.createdAt,
  });
  final String id;
  final String subjectId;
  final String title;
  final String url;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'title': title,
    'url': url,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudyResource.fromJson(Map<String, dynamic> json) => StudyResource(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String? ?? 'Study resource',
    url: json['url'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class FocusSession {
  const FocusSession({
    required this.id,
    required this.durationMinutes,
    required this.startedAt,
    this.elapsedSeconds = 0,
    this.paused = false,
    this.completedAt,
    this.cancelledAt,
  });
  final String id;
  final int durationMinutes;
  final DateTime startedAt;
  final int elapsedSeconds;
  final bool paused;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  bool get completed => completedAt != null;
  bool get active => completedAt == null && cancelledAt == null;
  FocusSession copyWith({
    DateTime? startedAt,
    int? elapsedSeconds,
    bool? paused,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) => FocusSession(
    id: id,
    durationMinutes: durationMinutes,
    startedAt: startedAt ?? this.startedAt,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    paused: paused ?? this.paused,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'durationMinutes': durationMinutes,
    'startedAt': startedAt.toIso8601String(),
    'elapsedSeconds': elapsedSeconds,
    'paused': paused,
    'completedAt': completedAt?.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
  };
  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    durationMinutes: json['durationMinutes'] as int,
    startedAt: DateTime.parse(json['startedAt'] as String),
    elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    paused: json['paused'] as bool? ?? false,
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String),
    cancelledAt: json['cancelledAt'] == null
        ? null
        : DateTime.parse(json['cancelledAt'] as String),
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Map<String, dynamic> toJson() => {
    'id': id,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };
  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String? ?? '',
  );
}

class Quiz {
  const Quiz({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.questions,
  });
  final String id;
  final String subjectId;
  final String title;
  final List<QuizQuestion> questions;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'title': title,
    'questions': questions.map((question) => question.toJson()).toList(),
  };
  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String,
    questions: (json['questions'] as List)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.answers,
    required this.score,
    required this.completedAt,
  });
  final String id;
  final String quizId;
  final List<int> answers;
  final int score;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'quizId': quizId,
    'answers': answers,
    'score': score,
    'completedAt': completedAt.toIso8601String(),
  };
  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    id: json['id'] as String,
    quizId: json['quizId'] as String,
    answers: (json['answers'] as List).cast<int>(),
    score: json['score'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}

class Flashcard {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.reviewCount = 0,
    this.nextReviewAt,
  });
  final String id;
  final String front;
  final String back;
  final int reviewCount;
  final DateTime? nextReviewAt;

  Flashcard copyWith({int? reviewCount, DateTime? nextReviewAt}) => Flashcard(
    id: id,
    front: front,
    back: back,
    reviewCount: reviewCount ?? this.reviewCount,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'front': front,
    'back': back,
    'reviewCount': reviewCount,
    'nextReviewAt': nextReviewAt?.toIso8601String(),
  };
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    front: json['front'] as String,
    back: json['back'] as String,
    reviewCount: json['reviewCount'] as int? ?? 0,
    nextReviewAt: json['nextReviewAt'] == null
        ? null
        : DateTime.parse(json['nextReviewAt'] as String),
  );
}

class FlashcardSet {
  const FlashcardSet({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.cards,
    this.lastStudiedAt,
  });
  final String id;
  final String subjectId;
  final String title;
  final List<Flashcard> cards;
  final DateTime? lastStudiedAt;

  FlashcardSet copyWith({List<Flashcard>? cards, DateTime? lastStudiedAt}) =>
      FlashcardSet(
        id: id,
        subjectId: subjectId,
        title: title,
        cards: cards ?? this.cards,
        lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'title': title,
    'cards': cards.map((card) => card.toJson()).toList(),
    'lastStudiedAt': lastStudiedAt?.toIso8601String(),
  };
  factory FlashcardSet.fromJson(Map<String, dynamic> json) => FlashcardSet(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    title: json['title'] as String,
    cards: (json['cards'] as List)
        .map((card) => Flashcard.fromJson(card as Map<String, dynamic>))
        .toList(),
    lastStudiedAt: json['lastStudiedAt'] == null
        ? null
        : DateTime.parse(json['lastStudiedAt'] as String),
  );
}
