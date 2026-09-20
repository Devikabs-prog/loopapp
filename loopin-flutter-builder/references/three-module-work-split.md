# LOOPIN Three-Module Work Split

Use this split when three members need to build LOOPIN in parallel and later merge into one Flutter project. The split is based on feature ownership, not three separate apps.

## Shared contract phase — everyone agrees before parallel work

Create and review one short contract commit before the three branches diverge:

- package name, environment configuration, Flutter/Dart versions, lint rules, and dependency list
- app theme tokens, shared widgets, error/loading/empty-state patterns, and route naming
- entity IDs, UTC timestamp convention, `createdAt`/`updatedAt`, ownership fields, and soft-delete/sync fields if needed
- repository/use-case interfaces and controller conventions
- navigation shell and route map with placeholder destinations
- database migration policy and table ownership
- domain events for cross-module effects, such as `TaskCompleted`, `FocusSessionCompleted`, `QuizAttemptSubmitted`, and `LessonCompleted`

Do not have multiple members edit the same shared file after this point unless the change is coordinated. Prefer additive files and feature-local folders.

## Module 1 — App foundation and productivity core

### Owner

Own the app shell and the student planning loop.

### Scope

- project setup, theme, router, Riverpod/provider wiring, dependency injection
- authentication and profile setup
- Drift database bootstrap, migrations, common DAO/repository infrastructure
- Home/dashboard aggregation and reusable state widgets
- tasks and calendar events: CRUD, details, agenda/month views
- local reminders, notification channels, scheduling, cancellation/rescheduling, notification deep links
- settings that directly control task/reminder behavior

### Feature folders

`app/`, `core/`, `data/local/`, `features/auth/`, `features/profile/`, `features/home/`, `features/calendar/`, `core/notifications/`, and `services/reminder_engine/`.

### Public contracts for other modules

- current authenticated user/profile
- task, event, and reminder repository interfaces
- app routes and navigation shell
- shared database access conventions
- domain event publishing mechanism

### Acceptance slice

Sign in -> create a task -> see it on Home -> schedule a reminder -> mark it complete -> emit `TaskCompleted`.

## Module 2 — Focus and learning engine

### Owner

Own the study activity and active-recall experience.

### Scope

- focus setup, custom timer, Pomodoro, pause/resume/end, restore-after-restart, summary
- focus session persistence and completion notification integration
- subjects, topics, lessons, bookmarks, and lesson completion
- note metadata and local note-resource representation; defer remote upload to Module 3
- manual quiz authoring/storage, quiz session, timer, scoring, explanations, attempt history
- feature-local progress facts such as focus minutes, lessons completed, and quiz accuracy

### Feature folders

`features/focus/`, `features/learning/`, `features/quiz/`, and their repositories/use cases/controllers/widgets.

### Public contracts for other modules

- `FocusSessionCompleted`, `LessonCompleted`, and `QuizAttemptSubmitted` events
- read-only progress query interfaces or aggregate DTOs
- quiz/lesson completion records that can be consumed by rewards and analytics

### Acceptance slice

Choose a subject -> complete a lesson -> start and finish a focus session -> take a quiz -> persist the result and emit completion events.

## Module 3 — Progression, insights, and optional integrations

### Owner

Own the motivation layer, user controls, and capabilities that should be added after the local core is stable.

### Scope

- XP ledger, levels, streaks, achievements, anti-repeat/anti-exploit rules
- avatar catalog, inventory, equipped state, rewards/shop
- progress dashboards, aggregate queries, charts, date ranges, empty analytics guidance
- settings hub, notification/privacy controls, quiet hours, consent controls, sync status
- Firestore/Storage sync queue and conflict fallback
- note upload/processing status
- secure AI assistant backend contract and client integration
- optional Google Calendar import-first integration
- Android-native bridges, permission center enhancements, and release hardening

### Feature folders

`features/gamification/`, `features/avatar/`, `features/progress/`, `features/settings/`, `features/sync/`, `features/assistant/`, plus `services/reward_engine/`, remote data sources, and Android bridge code.

### Public contracts for other modules

- reward service that consumes domain events and writes XP ledger entries
- progress query interfaces/DTOs
- settings and consent interfaces
- sync metadata and remote mapping rules

### Acceptance slice

Consume task/focus/lesson/quiz events -> award XP safely -> update level/streak/achievement -> display progress and avatar reward state.

## Ownership rules that prevent merge conflicts

- Module 1 owns the database bootstrap and migration runner; Modules 2 and 3 add feature tables/migrations through agreed migration files, never by rewriting Module 1’s existing migrations.
- Each module owns its own `features/<name>/` tree. Shared code changes require a small contract PR first.
- Module 2 never writes XP directly; it emits completion facts. Module 3 is the sole owner of reward rules and XP ledger writes.
- Module 3 consumes stable local interfaces; cloud/AI/native work must not become a compile-time dependency of Modules 1 or 2.
- Avoid barrel-file churn. Prefer explicit imports and additive route registrations.
- Keep generated files, lockfiles, and formatting changes out of feature commits unless required by the dependency change.

## Branch and merge order

1. `codex/loopin-contracts`: shared scaffold, contracts, route placeholders, database conventions.
2. `codex/loopin-module-1-productivity`: foundation and planning loop.
3. `codex/loopin-module-2-study`: focus, learning, and quizzes.
4. `codex/loopin-module-3-progression`: rewards, analytics, settings, and integrations.

Merge Module 1 first, then Module 2, then Module 3. Resolve conflicts in shared contracts intentionally, run migrations from a clean database, and run the full test suite after each merge. If the team uses Git worktrees, give each member a separate worktree and keep the contract branch as the common base.

## Integration checklist

- all three modules compile against the same Flutter/Dart and dependency lockfile
- routes are registered once and point to real screens or explicit placeholders
- each module’s repositories are wired through the agreed provider/container
- a fresh install creates the complete local schema without manual database edits
- domain events are idempotent or deduplicated where retries are possible
- offline task, focus, lesson, quiz, and reward flows work before cloud integrations are enabled
- notification IDs and payloads do not collide across modules
- module-level tests pass, then the thin vertical slice passes end to end
