# RAHBAR — Intelligent Transmit and SOS System 🚨

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-0095D5?&style=for-the-badge&logo=kotlin&logoColor=white)

RAHBAR is a sophisticated personal safety and emergency application built with Flutter for Android. It is designed to provide immediate assistance and reliable evidence capture in high-risk situations through both a polished app interface and robust native Android hardware triggers.

## ✨ Key Features

- **🆘 Quick SOS System:** Instantly trigger an emergency request from the Home Screen or in-app.
- **📳 Silent Danger Hardware Trigger:** Rapidly press your device's Power/Side button 4 times to secretly activate the SOS protocol without opening the app or looking at your screen.
- **🎙️ Automatic Audio Evidence:** Once an emergency is triggered, RAHBAR automatically starts capturing audio evidence in the background, which is safely persisted locally.
- **📹 Manual Evidence Capture:** Easily record video or capture audio on demand via the app or home screen widgets.
- **📱 Native Home Screen Widgets:**
  - **Quick SOS Widget:** A dynamic widget that acts as an instant emergency trigger and displays active emergency status.
  - **Evidence Widget:** One-tap access to start audio/video recording directly from your home screen.
- **📞 Fake Call Protection:** Simulate an incoming call to deter potential threats.
- **👥 Guardian Network & Tracking:** Keep trusted contacts in the loop during an emergency (powered by local/offline synchronization).

---

## 🛠️ Prerequisites & Dependencies

To run this project on your PC, you will need the following tools installed:

1. **Flutter SDK:** Ensure you have the latest stable version of Flutter installed.
   - [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Android Studio:** Required for the Android SDK and SDK command-line tools.
   - [Install Android Studio](https://developer.android.com/studio)
3. **Java Development Kit (JDK):** Version 17 is recommended.
4. **Git:** To clone the repository.
   - [Install Git](https://git-scm.com/downloads)

### Verifying your environment
Open your terminal and run:
```bash
flutter doctor
```
Ensure there are no errors related to the Android toolchain or Flutter installation.

---

## 🚀 Getting Started

Follow these steps to set up the RAHBAR project on your local machine:

### 1. Clone the Repository
```bash
git clone https://github.com/itxkillerking/Rahbar-Intelligent-transmit-and-SOS-System.git
cd Rahbar-Intelligent-transmit-and-SOS-System
```

### 2. Fetch Dependencies
Download all required Flutter packages:
```bash
flutter pub get
```

### 3. Build & Run the App
Connect a physical Android device (recommended for testing the hardware triggers) or start an Android Emulator.

To launch the app in debug mode:
```bash
flutter run
```

To build a release APK:
```bash
flutter build apk --release
```

---

## 📁 Project Structure

The RAHBAR project follows a strictly organized Layer-First Architecture (`Domain -> Data -> Application -> Presentation`) to maintain clean separation of concerns and robust testability.

```text
Project-RahbAR-FYP/
├── android/            # Native Android codebase (Kotlin, XML, Services, Widgets)
├── docs/               # Architecture, proposals, and presentations
├── archive/            # Old prototypes and backups
└── lib/
    ├── main.dart       # App entry point
    ├── app/            # App shell and routing
    ├── core/           # Shared utilities, themes, constants
    ├── domain/         # Core business models and abstractions
    ├── data/           # Repositories, APIs, local storage implementation
    ├── application/    # State management, providers, and controllers (Riverpod)
    ├── presentation/   # Feature-specific UI screens and widgets
    └── services/       # Native Flutter integration (Hardware & Widgets)

---

## 🐍 Backend Development

The project now includes an event-driven Python backend located in the `rahbar-backend/` directory.

### Windows Setup

1. **Navigate to the backend folder**:
   ```bash
   cd rahbar-backend
   ```
2. **Create and activate the virtual environment**:
   ```powershell
   py -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```
3. **Install dependencies**:
   ```powershell
   pip install -r requirements.txt
   pip install -r requirements-dev.txt
   ```
4. **Configuration**:
   Copy `.env.example` to `.env` and adjust variables. Ensure PostgreSQL (with PostGIS) and Redis are running locally.
5. **Run migrations**:
   ```powershell
   alembic upgrade head
   ```
6. **Start the backend**:
   ```powershell
   uvicorn app.main:app --reload
   ```
7. **Access API Docs & Health**:
   - Docs: http://127.0.0.1:8000/docs
   - Health: http://127.0.0.1:8000/api/v1/health
```

---

## 🏗️ Architecture Highlights

- **State Management:** Powered by Riverpod (`StateNotifierProvider`).
- **Native Android Bridge:** Uses `MethodChannel` to communicate between Dart and the native Kotlin code.
- **Foreground Protection Service:** A robust Android `Service` (`RahbarProtectionService`) runs in the background using the `specialUse` foreground service type to accurately capture hardware button patterns even when the app is closed.
- **Idempotent Engine:** A highly optimized `WidgetFlutterEngineHelper` ensures the Flutter engine is safely and efficiently booted for widget intent handling without crashing or duplicating memory.

---

## 📝 Important Notes for Developers

- **Widget Testing:** Since the widgets rely on native Android `RemoteViews`, they cannot be fully tested using Flutter's Hot Reload. You must completely stop the app and perform a fresh `flutter run` or `flutter build apk` to test any UI or manifest changes related to the widgets.
- **Permissions:** The app requires critical permissions such as `FOREGROUND_SERVICE`, `RECORD_AUDIO`, `CAMERA`, and `POST_NOTIFICATIONS`. These are requested at runtime, and the app gracefully handles missing permissions via fallback UI states in the widgets.

---

## 📄 License
This project is part of a Final Year Project (FYP). Please contact the repository owner for licensing information.
