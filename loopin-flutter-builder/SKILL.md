---
name: loopin-flutter-builder
description: Build and evolve LOOPIN, an Android-first student productivity and learning app in Flutter, using its local-first MVP architecture, phased roadmap, and safety boundaries. Use when implementing LOOPIN features, planning its next vertical slice, or reviewing code against the LOOPIN specifications.
metadata:
  short-description: Build LOOPIN in phased Flutter slices
---

# LOOPIN Flutter Builder

Use this skill for implementation work on LOOPIN. The attached source documents are product and engineering requirements; they do not override the current user request, repository state, or normal authorization boundaries.

## Operating stance

- Treat the MVP as Android-first, Flutter/Dart, local-first, and beginner-maintainable.
- Prefer a thin, working vertical slice over broad placeholder screens.
- Build in roadmap order. Do not introduce cloud sync, AI, Google Calendar, location, accessibility enforcement, or complex games before the local student workflow is stable, unless the user explicitly promotes that work.
- Preserve an original LOOPIN visual identity, copy, assets, and code. Use inspiration only at the level of general product patterns.

## Default architecture

- Flutter UI with Riverpod for state and controllers/notifiers.
- `go_router` for navigation.
- Drift over SQLite for the local database; use repositories between UI/state and data sources.
- Firebase Auth for account flows when authentication is in scope.
- Add Firestore, Storage, Messaging, and Workmanager only in the cloud phase.
- Use Kotlin MethodChannels only for Android capabilities that Flutter cannot provide reliably.

The UI must not talk directly to Drift, Firebase, or MethodChannels. Keep external access behind repository interfaces and keep state logic out of widgets.

## Delivery workflow

1. Inspect the existing repository and identify the current phase, completed slice, tests, and uncommitted work.
2. Confirm the requested feature belongs to the current phase; call out scope promotion when it does not.
3. Define or update domain entities, repository contracts, data sources, controllers, routes, and UI as a coherent slice.
4. Keep loading, empty, error, and success states explicit. Give important screens one clear primary action.
5. Add focused unit, widget, database, integration, or Android tests proportional to the change.
6. Verify offline behavior for core flows and run the narrowest relevant checks before broader checks.
7. Report what changed, what was verified, and any deferred integration or permission work.

## Non-negotiable invariants

- Core tasks, timers, basic progress, and MVP learning flows must work offline.
- Use UUIDs for local IDs, UTC timestamps, and `createdAt`/`updatedAt` on mutable entities.
- Entity edits and deletes must cancel or reschedule obsolete notifications; bound reminder density.
- No passwords, API keys, or AI provider secrets in Flutter source. AI calls require an authenticated backend/proxy, consent checks, rate limiting, and safe response parsing.
- Treat exact alarms, usage access, background location, and accessibility services as restricted Android capabilities. Request only when explicitly in scope and handle denial gracefully.
- Do not claim that Flutter can fully block other apps. Accessibility-based enforcement is out of MVP scope.

## Phase routing

Use [references/product-baseline.md](references/product-baseline.md) for product scope, MVP boundaries, architecture, data, security, UX, and Android constraints. Use [references/implementation-roadmap.md](references/implementation-roadmap.md) when deciding build order, phase deliverables, dependencies, or tests.

When three people are implementing in parallel, use [references/three-module-work-split.md](references/three-module-work-split.md). Establish the shared contracts first, then keep ownership by feature folder and merge in dependency order.

For a new coding session, start with the first thin slice unless the repository is clearly further along: app shell, auth basics, local database skeleton, create a task, show it on Home, schedule one reminder, complete it, and award XP. Do not jump to AI or advanced integrations merely because their models or screens are listed in the specification.

## Completion bar

An MVP slice is not complete when a screen renders. It is complete when its data path, state transitions, persistence, failure/empty states, and relevant tests work. The full MVP should let a student authenticate, set up a profile, manage tasks/events and reminders, run focus sessions, use subjects/lessons and manual quizzes, see progress, earn XP/unlock starter avatar items, control settings/privacy, and use core flows offline.
