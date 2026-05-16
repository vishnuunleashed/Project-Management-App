# Project Management App With Enhanced Features Such as Offline Capability, Firebase, Dashboards

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

## 🛠️ Technology Stack & Dependencies

The project relies on a carefully curated set of packages to deliver a premium, high-performance experience. Below is a breakdown of the core dependencies and their purpose in the application:

### State Management & Architecture
- **`flutter_riverpod`**: Provides robust, scalable state management and dependency injection, ensuring the UI remains highly responsive and decoupled from business logic.

### Core & Networking
- **`dio` & `http`**: Handles advanced HTTP networking, API interactions, and RESTful requests.
- **`go_router`**: Manages declarative routing, navigation, and deep linking.
- **`connectivity_plus`**: Monitors network connection state for offline/online capability switching.

### Storage & Caching
- **`hive` & `hive_flutter`**: Blazing fast, local NoSQL database used for offline data caching.
- **`shared_preferences`**: Lightweight persistence for user settings and preferences.
- **`flutter_secure_storage`**: Encrypted, secure storage for sensitive information like authentication tokens.
- **`cached_network_image`**: Efficient downloading, rendering, and caching of web images.

### Firebase & Notifications
- **`firebase_core` & `firebase_messaging`**: Core Firebase services and push notifications via Firebase Cloud Messaging (FCM).
- **`flutter_local_notifications`**: Powers complex local device notifications.

### Mapping & Location
- **`flutter_map` & `latlong2`**: Renders interactive maps and handles geographical coordinates.
- **`location` & `geocoding`**: Retrieves the device's GPS location and translates coordinates into human-readable addresses.
- **`proj4dart`**: Coordinate reference system transformations for advanced mapping needs.

### Media & Documents
- **`image_picker` & `file_picker`**: Native dialogs for selecting images, videos, and documents from the device.
- **`syncfusion_flutter_pdfviewer`**: High-quality, robust rendering of PDF documents.
- **`photo_view`**: Provides zoomable, interactive image viewing capabilities.
- **`open_filex`**: Opens downloaded or locally generated files using the device's native applications.

### UI & UX Components
- **`fl_chart`**: Renders complex, interactive graphs and dashboards (e.g., for analytics).
- **`animated_theme_switcher`**: Seamless, animated transitions between light and dark themes.
- **`flutter_animate`**: Adds highly customizable micro-animations to enhance the user experience.
- **`flutter_slidable`**: Enables intuitive swipe-to-reveal actions on list items.
- **`dropdown_search`**: Searchable dropdown menus for large datasets.
- **`carousel_slider`**: Interactive image and content carousels.
- **`flutter_svg`**: Crisp rendering of vector graphics (SVG) across all screen densities.
- **`scrollable_positioned_list` & `expandable_page_view`**: Advanced UI controls for scrolling to specific indexes and auto-resizing page views.
- **`visibility_detector`**: Tracks when widgets become visible or hidden in the viewport to trigger animations or lazy loading.

### System & Background Integrations
- **`workmanager`**: Enables reliable background task execution, essential for offline data syncing when the app is closed.
- **`permission_handler`**: Streamlines the process of requesting OS-level user permissions (camera, location, storage).
- **`webview_flutter`**: Displays external web content directly within the application.
- **`url_launcher`**: Opens external URLs, launches phone dialers, or opens email clients.
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
