import 'package:flutter_test/flutter_test.dart';
import 'package:loopapp/features/study/models/study_models.dart';

void main() {
  test('study note preserves content and generated summary', () {
    final note = StudyNote(
      id: 'note-1',
      subjectId: 'subject-1',
      title: 'Biology',
      content: 'Cells have membranes. Membranes control movement.',
      createdAt: DateTime.utc(2026, 9, 14),
      summary: 'Cells have membranes. Membranes control movement.',
    );

    final restored = StudyNote.fromJson(note.toJson());
    expect(restored.subjectId, note.subjectId);
    expect(restored.content, note.content);
    expect(restored.summary, note.summary);
  });

  test('flashcard review metadata round trips', () {
    final card = Flashcard(
      id: 'card-1',
      front: 'Term',
      back: 'Definition',
      reviewCount: 2,
      nextReviewAt: DateTime.utc(2026, 9, 16),
    );

    final restored = Flashcard.fromJson(card.toJson());
    expect(restored.reviewCount, 2);
    expect(restored.nextReviewAt, card.nextReviewAt);
  });

  test('lesson bookmark and difficulty round trip', () {
    final lesson = Lesson(
      id: 'lesson-1',
      subjectId: 'subject-1',
      title: 'Algebra',
      content: 'Review equations.',
      bookmarked: true,
      difficulty: 'hard',
    );

    final restored = Lesson.fromJson(lesson.toJson());
    expect(restored.bookmarked, true);
    expect(restored.difficulty, 'hard');
  });
}
