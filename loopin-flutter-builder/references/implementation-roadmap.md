# LOOPIN Implementation Roadmap

Derived from `LOOPIN_Implementation_Plan.md` (v1.0, 2026-09-12). Use this as the default sequencing guide; explicit user scope can promote a later phase.

## Prerequisites

Before feature screens: theme, router, Riverpod/dependency setup, Drift database, repository boundaries, and reusable loading/error/empty widgets. Before cloud: stable models, repository contracts, and sync metadata. Before AI: authenticated user flow, note/file model, backend contract, and privacy/consent UI.

## Phases

1. Foundation: app shell, theme, router, Riverpod, Drift, placeholder routes, startup/route tests.
2. Auth/profile: sign-up, login, logout, password reset, profile setup, persistent signed-in flow.
3. Local data: Drift tables/DAOs, migrations, repositories, error mapping, seed/empty behavior.
4. Home: aggregate today/upcoming tasks, XP/level/streak, quick actions, section-level loading/error states.
5. Tasks/calendar/reminders: CRUD, agenda/calendar, adaptive reminder basics, local notification scheduling, cancel/reschedule, notification deep links.
6. Focus: setup, custom/Pomodoro timer, pause/resume/end, persisted active session restore, summary, completion notification, valid-session XP.
7. Learning: subjects, topics, lessons, bookmarks, completion tracking, learning-to-XP link.
8. Quiz: stored question sets, attempt lifecycle, scoring, timer expiry, explanations, history, anti-repeat XP rules.
9. Gamification/avatar: XP ledger, levels, streaks, achievements, catalog/inventory/equipped state, unlock/equip flows.
10. Progress/settings: aggregate queries, charts/date ranges, empty analytics guidance, notification toggles, quiet hours, privacy/consent settings.
11. Cloud/uploads: Firestore and Storage mapping, offline sync queue, reconnect replay, basic conflict fallback, sync status, note metadata/upload retry.
12. AI/external integrations: secure assistant endpoints, concept explanation, summarization, quiz generation, task breakdown, Google Calendar import-first sync.
13. Android/release: MethodChannels, usage access only if approved, calendar/location bridges only if needed, permission denial paths, release hardening, signing, low-end device checks, Play readiness.

## Recommended initial dependencies

Start with `flutter_riverpod`, `go_router`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `intl`, `uuid`, `connectivity_plus`, `flutter_secure_storage`, `flutter_local_notifications`, `timezone`, `permission_handler`, and `fl_chart`. Add Firebase Auth in the auth phase; Firestore/Storage/Messaging/Workmanager in cloud; `file_picker` for notes; `google_sign_in`/`googleapis` for Google integrations.

## Thin vertical slice

Prioritize: login -> profile setup -> add task -> save locally -> show on Home -> receive one reminder -> mark complete -> award XP. This validates app shell, auth, state, database, notification plumbing, and the first real user value.

## Cross-cutting checks

- UI never accesses data sources directly.
- Every phase includes the smallest meaningful tests before moving on.
- Test CRUD and persistence, timer restoration, reminder cancellation, empty/error states, scoring, XP/repeat rules, offline queue/replay, permission denial, and notification deep links as each feature lands.
- Keep advanced animations, mini-games, geofencing, accessibility enforcement, OCR, and rich sync conflict UI out of the core MVP.

## MVP done criteria

A student can authenticate, configure a profile, manage tasks/events, receive reminders, run focus sessions, create subjects/lessons, take quizzes, view progress, earn XP/unlock avatar items, control settings/privacy, and use core flows reliably offline.
