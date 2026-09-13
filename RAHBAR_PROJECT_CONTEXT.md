# RAHBAR PROJECT CONTEXT & PROGRESS REPORT

**Purpose of this Document:**
This document serves as a comprehensive knowledge transfer and state-of-the-project report for the RAHBAR Final Year Project (FYP). It is designed to allow any AI assistant or developer to quickly understand the project's purpose, architecture, completed phases, and future roadmap without making incorrect assumptions about the current codebase.

---

## 1. PROJECT OVERVIEW
RAHBAR is a professional Android safety and emergency-response prototype. The goal is to provide users with a secure way to trigger emergency protocols, either openly (Normal SOS) or covertly (Silent Danger Mode), and to securely relay evidence and telemetry to Guardians and a Command Center.

**Key constraints:**
*   This is currently a **prototype** aimed at a university FYP showcase.
*   Production infrastructure (real backend, real database, real GPS) is simulated using mock services to maintain a smooth UI/UX presentation.
*   Previous concepts like "Smart Transit Integration" and "CNIC database" have been **permanently removed**. Do not attempt to add them.

## 2. TECHNOLOGY STACK & ARCHITECTURE
*   **Framework:** Flutter (Dart)
*   **Target Platform:** Android (Android SDK 36 targeted)
*   **State Management:** Riverpod (`flutter_riverpod`)
*   **Architecture Pattern:** Feature-first layered architecture keeping Business Logic entirely separate from UI.
    *   `lib/domain/`: Core models (`Emergency`, `TelemetryRecord`) and service interfaces.
    *   `lib/data/`: Mock implementations of services (e.g., `MockLocationService`, `MockSynchronizationService`).
    *   `lib/application/`: Riverpod Controllers (`EmergencyController`, `TelemetryController`, `FakeCallController`).
    *   `lib/ui/`: Presentation layer containing `AppShell`, screens, widgets, and `AppTheme`.

## 3. CORE FEATURES & LOGIC

### Emergency State Machine
Managed by `EmergencyController`. The core states flow as follows:
`Idle` -> `TriggerDetected` -> `AwaitingConfirmation` -> `EmergencyActivated` -> `Sending` -> `Sent` or `OfflinePending` -> `Resolved`.
*   **Normal SOS:** Requires user confirmation before activating.
*   **Silent Danger:** Bypasses confirmation and activates immediately. (Triggered via UI currently; real 4-press hardware button integration is deferred).

### Fake Call Protection
Managed by `FakeCallController`. Limits users to a threshold of 4 simulated fake calls to prevent abuse. If the threshold is reached, the feature is blocked until a prototype reset occurs.

### Offline Resilience & Telemetry
Managed by `TelemetryController`. The prototype utilizes an offline-first "store-and-forward" approach.
*   When offline, records are marked as `"Cached Locally"`.
*   When online, a simulated sync converts them to `"Pending Sync"` and finally `"Synced"`.

---

## 4. COMPLETED PHASES (History)

### Phase 1: Foundation (DONE)
*   Established the Flutter project structure and Riverpod state management.
*   Created domain models and the central `EmergencyController` state machine.
*   Set up dependency injection via `providers.dart`.

### Phase 2: UI/UX & Navigation (DONE)
*   Implemented a clean, Material 3 safety-focused `AppTheme` (utilizing safe greens, warning ambers, and emergency reds).
*   Created the 4-tab Bottom Navigation using `IndexedStack` (Home, Emergency, Guardians, Settings).
*   Nested sub-features (Tracking, Evidence) securely within the Emergency flow.
*   Migrated developer controls to the Settings screen to keep the normal user flow clean.

### Batch 7: Offline Resilience & Telemetry Prototype (DONE)
*   Created the `TelemetryRecord` model and `TelemetryController`.
*   Upgraded `TrackingScreen` to dynamically display prototype network status, active mock location, and a live "Pending Sync" counter.
*   Upgraded `DevelopmentControls` to allow manual simulation of Offline/Online states, Mock Telemetry generation, and Prototype Syncing.

---

## 5. CURRENT ACTIVE WORK (Batch 8)
**Batch 8: Final Prototype Polish & Full-System Review (PENDING EXECUTION)**
*   **Goal:** Polish existing UI and wording to ensure the prototype is presentation-ready.
*   **Tasks:** 
    1.  Fix the `CommandCenterScreen` placeholder by adding a proper `AppBar` and professional wording indicating it is a deferred web-based system.
    2.  Update wording in the `EvidenceScreen` from `"Synced to Vault"` to `"Prototype Media - Offline Cache"` to better align with the offline capabilities established in Batch 7.
*   *Note: No major features or architecture changes are permitted in Batch 8.*

---

## 6. FUTURE ROADMAP (Deferred Phases)
Any AI working on this project must **not** attempt these until explicitly instructed by the user:
1.  **Android Hardware Trigger:** Implementing the native Android background service to detect 4 rapid power-button presses and bridge it to Flutter for the Silent Danger flow. (Requires regenerating the `android/` project folder).
2.  **Real Local Storage:** Replacing mock data repositories with real SQLite/Hive/Isar databases.
3.  **Real Device Integrations:** Implementing real GPS polling and real Camera/Mic recording for the Evidence vault.
4.  **Backend Integration:** Connecting the app to a real REST API, WebSockets, FCM, and PostgreSQL backend for real Guardian and Command Center synchronization.
5.  **Command Center Web App:** Building a separate web-based operator system.

---

## 7. CRITICAL RULES FOR AI ASSISTANTS
If you are an AI reading this document to assist the user:
1.  **Do NOT redesign the architecture** or change the module structure.
2.  **Do NOT add production complexity** (like real backend logic or real databases) unless the user's specific batch instructions require it.
3.  **Treat the repository as the absolute truth** for current implementation, and this document as the truth for project scope.
4.  **Work in small, strictly controlled batches.** Always inspect the code, propose a plan, and wait for user approval before modifying files.
5.  **Preserve existing functionality.** Do not break the Emergency State Machine or the 4-tab AppShell navigation.
