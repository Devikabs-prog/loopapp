# LOOPIN Product Baseline

Derived from `LOOPIN_Technical_Specification.md` (v1.0, 2026-09-12). This reference captures reusable decisions rather than reproducing the full specification.

## Product shape

LOOPIN combines student task planning, calendar/reminders, focus sessions, structured learning, quizzes, progress analytics, XP/streaks/achievements, avatar rewards, and optional AI assistance. The target user benefits from small actionable steps, low visual overload, positive reinforcement, and reliable offline use.

## MVP boundary

MVP includes onboarding, email/password auth, profile setup, Home, tasks and built-in calendar, local reminders with basic adaptive logic, focus/Pomodoro, subjects and lessons, manual quizzes, progress, XP/levels/streaks, starter avatar unlocks, settings, notification/privacy controls, and a local-first Drift database.

Exclude until the core loop is stable: accessibility-based blocking, background geofencing, complex two-way Google Calendar sync, full AI note summarization without a backend, and heavy mini-games.

## Data and feature domains

Core entities include User, UserSettings, Task, CalendarEvent, StudySession, Subject, Topic, Lesson, NoteResource, NoteSummary, Quiz, Question, AnswerOption, QuizAttempt, XP ledger entries, achievements, rewards, avatar catalog/inventory/state, notification records, reminder strategy, and sync queue items. Mutable records use UTC timestamps and local UUIDs.

Feature areas should remain separated: auth/profile, calendar/reminders, focus, learning, quiz, gamification, avatar, progress, settings, sync, and assistant. Controllers/notifiers coordinate use cases; repositories isolate Drift, Firebase, storage, and native bridges.

## UX and state requirements

Keep the dashboard intentionally uncluttered. Important screens need an obvious primary action and loading, empty, error, and success handling. Navigation centers on Home, Calendar, Focus, Learn, and Progress, with secondary routes for rewards, avatar, settings, privacy, notifications, sync, and assistant. Notification taps should deep-link to the relevant entity when supported.

## Integrations and constraints

- Firebase Auth is appropriate for account flows; Firestore/Storage/Messaging are later cloud capabilities.
- Google Calendar requires OAuth scopes, sync-token handling, duplicate prevention, and conflict rules; import-only is the safer first mode.
- AI requires a user-authenticated backend/proxy, rate limiting, consent before sending notes, and no provider key in the mobile app.
- Usage stats, exact alarms, notification permissions, calendar provider access, location, and accessibility each have Android permission or Play-policy implications. Treat them as optional, explicit, and denial-tolerant.
- Flutter cannot reliably or fully block other apps across devices.

## Quality and security

Core workflows must continue offline. Log useful diagnostics without sensitive content. Never store passwords locally or secrets in source. Validate input and authorize remote records by the authenticated user. Cancel stale reminders after edits/deletes and prevent reward abuse through ledger-based XP and repeat/reward guards.
