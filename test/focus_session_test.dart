import 'package:flutter_test/flutter_test.dart';
import 'package:loopapp/features/study/models/study_models.dart';

void main() {
  test('focus session preserves active pause state and elapsed time', () {
    final session = FocusSession(
      id: 'focus-1',
      durationMinutes: 25,
      startedAt: DateTime.utc(2026, 9, 14, 10),
      elapsedSeconds: 420,
      paused: true,
    );

    final restored = FocusSession.fromJson(session.toJson());

    expect(restored.active, true);
    expect(restored.paused, true);
    expect(restored.elapsedSeconds, 420);
    expect(restored.durationMinutes, 25);
  });
}
