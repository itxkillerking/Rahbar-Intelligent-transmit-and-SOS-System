# RAHBAR Project Architecture & Documentation

## 1. RAHBAR Purpose
RAHBAR is a serious safety and emergency-response Android application prototype designed to allow users to request help during a dangerous situation. It focuses on scalability, reliability, and offline resilience. If successful, it may eventually be proposed for operational deployment with the Punjab Government.

## 2. Finalized Modules
- **Emergency System** (Normal & Silent Modes)
- **Guardian Integration**
- **Command Center Integration**
- **Offline Resilience & Synchronization**
- **Evidence & Telemetry System**

## 3. Emergency Modes
### Normal Emergency
The user interacts openly with the app:
1. User presses the SOS button on the main UI.
2. A confirmation prompt is displayed.
3. Upon confirmation, emergency is activated.
4. Data is prepared and sent to the RAHBAR Server, Guardian, and Command Center.
5. The emergency state is visibly shown on the device.

### Silent Danger Mode
The user triggers the emergency without making it obvious to potential attackers:
1. Triggered by **4 configured physical side-button presses**.
2. **No confirmation** is requested.
3. Emergency is activated immediately.
4. Data is sent to the RAHBAR Server, Guardian, and Command Center.
5. The UI maintains a normal-looking state to hide the SOS action.

## 4. Emergency Data Flow
1. **Trigger Detected:** (UI Button or Platform Service for Side-Button)
2. **Emergency Controller:** Processes the trigger.
3. **Emergency Activated:** State changes to Active.
4. **Local Repository:** Emergency state and critical telemetry (location, timestamp, battery) are saved locally first.
5. **Synchronization Service:** Attempts to send the data to the RAHBAR Server.
6. **Notification Service:** Alerts the Guardian and Command Center via the Server.

## 5. Offline Behavior
The architecture is **offline-first**:
- When internet is unavailable, emergency requests and telemetry are saved securely in local storage.
- The app maintains the emergency state locally.
- It will attempt fallback communication for critical data (e.g. SMS, to be designed later).
- Full synchronization with the server happens automatically once connectivity returns. Data is never lost.

## 6. Guardian Role
The Guardian is a designated contact who receives emergency notifications and can view relevant emergency information. Guardian functionality is architecturally separate from the Command Center.

## 7. Command Center Role
A dedicated system to receive alerts, verify info, review location and evidence, check status, and coordinate responses with nearby authorities. It is kept conceptually and architecturally separate from the Guardian system.

## 8. Flutter Architecture
The app follows a scalable feature-first and layered architecture. 
- **Presentation Layer:** UI widgets and state management.
- **Domain Layer:** Business logic, entities, and use-case definitions.
- **Data Layer:** Repositories, data sources (local and remote), and DTOs.
- **Services Layer:** Cross-feature capabilities (location, platform triggers, syncing).

Platform-specific code (e.g., hardware trigger detection) is strictly isolated using MethodChannels/Platform Interfaces. Business logic is never mixed directly into UI widgets.

## 9. Folder Structure
The structure allows for high scalability and separation of concerns:
```
lib/
├── core/             # Core configs, constants, errors, network, storage, theme, utils
├── features/         # Feature-based modules
│   ├── emergency/    # SOS UI, emergency state management
│   ├── guardian/     # Guardian connection and status
│   ├── command_center/# Command center data models
│   ├── tracking/     # Location tracking features
│   ├── evidence/     # Audio/Evidence management
│   └── settings/     # App settings
├── services/         # Cross-feature services (emergency, notification, location, storage, sync, platform)
├── app/              # App routing and global theme
└── main.dart         # Entry point
```

## 10. Mock-Service Strategy
During the prototype phase, real backend and platform connections will be simulated using Mock Implementations (e.g., `MockEmergencyRepository`, `MockLocationService`). The application will communicate with these mocks strictly through interfaces/contracts. This enables seamless substitution later without UI rewrite.

## 11. Future Production Replacement Strategy
Because the app relies on dependency injection and clean boundaries (interfaces), swapping out `MockEmergencyRepository` for a `FirebaseEmergencyRepository` or `RestApiEmergencyRepository` in the future will require zero changes to the UI or business logic. Platform services will be replaced with real Android MethodChannels.

## 12. Scalability Considerations
- **Separation of Concerns:** Features are decoupled.
- **State Management:** Prepared to handle many users, guardians, and complex states securely.
- **Offline Queues:** Robust local storage prepares the app for handling large emergency histories and poor network conditions.

## 13. Android-Specific Integration Points
The physical 4-press side-button trigger requires native Android implementation. It will be implemented using a background Android Service to monitor hardware key events. Flutter will communicate with this service via a clean `Platform Service` boundary. The side-button logic will absolutely not be tied directly to any Flutter Widget.

## 14. UI/UX Design Principles
- **Premium, Professional, Trustworthy:** Uses Material 3 Expressive design.
- **Clear Hierarchy & Easy Navigation:** Floating-style elements, clear status indicators.
- **Restrained Aesthetics:** Avoids excessive animations, gaming UI, or neon colors. Uses calm visuals for normal use, clear urgency for emergencies.
- **Silent Mode Integrity:** During Silent Danger Mode, the UI must strictly avoid "EMERGENCY SENT" screens or flashy animations, appearing as normal as possible. No user interaction or confirmation is required to finalize silent activation.

## 15. Emergency State Model
The emergency pipeline utilizes a state model decoupled from UI:
- `Idle`
- `TriggerDetected`
- `AwaitingConfirmation` (Normal Mode only)
- `EmergencyActivated`
- `Sending`
- `Sent`
- `OfflinePending`
- `Synchronizing`
- `Resolved`
- `Failed`
