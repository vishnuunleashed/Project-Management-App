# Sample Code Snippet With Enhanced Features Such as Offline Capability, Firebase, Dashboards

Welcome to the **Sample Project Enhanced Features** repository! This is a robust Flutter application template showcasing advanced features commonly required in modern, enterprise-grade applications. 

## 🚀 Key Features

* **Clean Architecture**: The codebase is strictly standardized on Clean Architecture principles, ensuring a clear separation of concerns across the `data`, `domain`, and `presentation` layers for high testability and maintainability.
* **Offline Capability & Local Storage**: Utilizes `hive` and `shared_preferences` to cache data locally, ensuring seamless functionality without an active internet connection. Background syncing is supported via `workmanager`.
* **Firebase Integration**: Fully integrated with Firebase for rich features including:
  * Firebase Cloud Messaging (FCM) for push notifications.
  * Firebase Storage for file uploads and management.
* **Interactive Dashboards & Charts**: Implements dynamic data visualization and dashboards using the `fl_chart` package.
* **State Management**: Built on `flutter_riverpod` for scalable, predictable, and testable state management across the app.
* **Advanced Routing**: Uses `go_router` for deep linking and declarative navigation.
* **Location Services**: Features mapping, geocoding, and location tracking using `flutter_map`, `geocoding`, and `location`.
* **Media & File Management**: Comprehensive support for viewing, picking, and caching media files utilizing `image_picker`, `file_picker`, `photo_view`, `cached_network_image`, and `open_filex`.
* **PDF Viewing**: Built-in support for rendering PDFs via `syncfusion_flutter_pdfviewer`.
* **Secure Storage**: Sensitive information is securely persisted using `flutter_secure_storage`.
* **Dynamic Theming**: Supports on-the-fly theme switching via `animated_theme_switcher` and uses Google's PlusJakartaSans and Righteous fonts.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK >=3.10.6)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Database**: [Hive](https://docs.hivedb.dev/)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **UI Components**: 
  - `fl_chart`
  - `carousel_slider`
  - `flutter_slidable`
  - `dropdown_search`
  - `flutter_svg`

## 📦 Project Structure

```text
lib/
├── data/           # Data layer: API clients, local storage, and data models
├── domain/         # Domain layer: Business logic, use cases, and repository interfaces
├── presentation/   # UI layer: Screens, widgets, and state management (Riverpod)
├── utils/          # Utility classes and helper functions
└── main.dart       # App entry point
```
*(Additional modules like `base`, `eraser-main`, and `dcc_module` are referenced as local packages.)*

## 🚦 Getting Started

### Prerequisites

* Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* Ensure you have Android Studio / Xcode configured for your target platforms.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repository-url>
   cd sample-project-enhanced-features
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```

## ⚙️ Configuration Notes

### Firebase
The project relies on Firebase. The iOS `GoogleService-Info.plist` and Android `google-services.json` are currently configured for `sample-project-space-n-design`. You should replace these files with the ones corresponding to your own Firebase project if you plan to utilize Firebase features in your environment.

### Local Packages
This application depends on several local packages located within the repository:
- `base/`
- `eraser-main/`
- `packages/dcc_module/`
Ensure these directories remain intact for the build to succeed.

## 📄 License
**Copyright © 2026 Vishnuprasad T R. All rights reserved.**

This is a private project solely maintained by Vishnuprasad T R. Unauthorized copying, modification, distribution, or use of this project, via any medium, is strictly prohibited without explicit permission.
