# FlowState ── Premium Task Management App

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.11.0-blue.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.0.0-blue.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Platform Support](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**FlowState** is a highly polished, recruiter-ready task management application built in Flutter. Designed to move away from generic, basic templates, FlowState implements a custom editorial **Rose Gold & Warm Terracotta** visual system, interactive widgets, animated checklists, and a solid data persistence layer.

---

## 🎨 Visual Identity & Theme

FlowState is themed around warmth, focus, and elegance:
*   **Warm Sand / Cream** (`#FDFBF7`) — Main background color providing a soft, paper-like visual surface.
*   **Rich Terracotta / Rust** (`#C96A53`) — Primary active brand color for buttons, selections, and emphasis.
*   **Soft Rose Gold** (`#E8C5C8`) — Accent color for filters, category chips, and decorative elements.
*   **Deep Espresso / Charcoal** (`#2B2525`) — Text color and dark mode surface backgrounds.
*   **Dynamic Theme Toggle** — Swap seamlessly between **Light Mode** and **Dark Mode** with an animated transition.

---

## 📸 Screenshots

*Place your screenshots in the [screenshots/](file:///d:/DHC-Internship-flutter/week_3/screenshots/) folder (e.g. `home_light.png`, `home_dark.png`, `add_task.png`, `task_details.png`) and they will display here:*

| Light Mode Dashboard | Dark Mode Dashboard |
|:---:|:---:|
| <img src="screenshots/home_light.png" width="320" alt="Home Screen Light Mode" /> | <img src="screenshots/home_dark.png" width="320" alt="Home Screen Dark Mode" /> |

| Add Task Form | Task Details & Inline Edit |
|:---:|:---:|
| <img src="screenshots/add_task.png" width="320" alt="Add Task Form" /> | <img src="screenshots/task_details.png" width="320" alt="Task Details & Edit View" /> |

---

## ✨ Features

*   🌅 **Custom Splash Screen**: Features a branded launcher entry using the customized FlowState logo (`logo.jpeg`) with custom adaptive colors matching the light theme.
*   📊 **Progress Dashboard**: A header card calculating task completion rates in real-time, backed by a gradient progress bar and motivational taglines.
*   🏷️ **Smart Categorization**: Sort tasks into **Work**, **Personal**, **Wellness**, **Finance**, and **Other** categories, each color-coded with distinct icon identifiers.
*   ⚡ **Interactive Checklist & Gestures**:
    *   Tapping the checkbox executes a scale/color pop checklist animation, crossing out titles and adjusting stats immediately.
    *   **Swipe-to-Dismiss**: Swipe any task tile to the left to delete it.
    *   **Undo Action**: Deletion triggers a clean bottom SnackBar with an **Undo** capability to restore the task instantly.
*   📝 **Inline Edit Mode**: View full notes, priority, and date inside the details view, and toggle edit mode to modify any properties inline without launching a new page route.
*   🔍 **Advanced Live Filters**: Filter tasks dynamically using search queries, category scrollbars, or segment toggles (All, Active, Completed).
*   💾 **Local Persistence**: Tasks are encoded to JSON and persisted using `SharedPreferences` so your database is preserved across application reboots.

---

## 🛠️ Tech Stack & Dependencies

*   **Framework**: [Flutter SDK](https://flutter.dev/) (Material 3)
*   **Language**: [Dart](https://dart.dev/)
*   **Local Storage**: [`shared_preferences`](https://pub.dev/packages/shared_preferences) for local state serialization.
*   **Localization & Date Formatting**: [`intl`](https://pub.dev/packages/intl) to parse and structure due dates.
*   **Launcher Icons Generator**: [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) to apply custom branding at build-time.

---

## 📦 APK Release & Installation

The Android compilation is fully complete. You can download and install the pre-compiled debug APK directly to test the application on real devices:

📍 **Release APK Location**:  
`build/app/outputs/flutter-apk/app-debug.apk`

*To install on a connected Android device:*
```bash
flutter install
```

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK installed](https://docs.flutter.dev/get-started/install)
*   An Android emulator, iOS simulator, or connected physical device.

### Installation
1. Clone this repository
2. Navigate to project root:
   ```bash
   cd week_3
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the code:
   ```bash
   flutter run
   ```

### Running Widget Tests
Run the suite to verify compilation and router setups:
```bash
flutter test
```
