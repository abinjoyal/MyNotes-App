# MyNotes

MyNotes is a feature-rich, cross-platform note-taking application built with Flutter. It helps you capture your ideas, manage your tasks, and keep everything organized in folders. It also provides advanced features such as exporting your notes as PDFs, pinning important items, and seamless Google Drive backup.

## ✨ Features

* **Rich Note Management**: Create, edit, and manage your notes effortlessly.
* **Tasks & Checklists**: Stay on top of your to-dos with built-in task management.
* **Folder Organization**: Categorize your notes and tasks into folders for a clutter-free experience.
* **Pin Important Items**: Pin your most crucial notes and tasks to the top for quick access.
* **Search Functionality**: Quickly find what you are looking for with the integrated search feature.
* **Trash / Recycle Bin**: Accidentally deleted something? Recover your notes and tasks from the Trash before they are permanently removed.
* **Google Drive Backup & Sync**: Keep your data safe by securely backing up your notes to Google Drive.
* **Export & Share**: Easily export your notes as PDFs or images, or print them directly from the app.
* **Cross-Platform Support**: Enjoy a seamless experience across Mobile, Web, and Desktop environments (features responsive layouts like sidebars and desktop views).
* **Modern Architecture**: Built using a feature-first, clean architecture approach with Riverpod for robust state management.

## 📸 Screenshots

*(Add screenshots of your application here. You can capture screenshots of your mobile and desktop layouts and place them in an `assets/screenshots/` folder, then link them like this: `![Dashboard](assets/screenshots/dashboard.png)`)*

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (version ^3.12.2 or higher)
* Dart SDK
* An IDE (like Android Studio, VS Code, or IntelliJ IDEA)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/mynotes.git
   cd mynotes
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Google Sign-In Configuration (For Backup Feature):**
   * Go to the [Google Cloud Console](https://console.cloud.google.com/).
   * Create a new project and configure the OAuth consent screen.
   * Generate OAuth 2.0 Client IDs for Android/iOS/Web as needed.
   * Update your project configurations (like `google-services.json` for Android or `GoogleService-Info.plist` for iOS) according to the official [google_sign_in documentation](https://pub.dev/packages/google_sign_in).

4. **Run the application:**
   ```bash
   flutter run
   ```

## 🏗️ Project Architecture

This project follows a feature-driven, clean architecture approach to maintain scalability and readability. The primary directories under `lib/` are:

* **`app/`**: Contains core application setup, including routing, themes, and global layout structures (e.g., sidebar and desktop layouts).
* **`core/`**: Houses shared resources used across the app, such as database services, extensions, utilities, exceptions, and common UI widgets.
* **`features/`**: The main business logic is split into standalone features:
  * `backup/`: Google Drive synchronization.
  * `folders/`: Directory management for notes.
  * `notes/`: Note creation and displaying logic.
  * `tasks/`: Task management.
  * `pin/`: Pinning logic for quick access.
  * `search/`: Searching capabilities.
  * `trash/`: Soft-delete mechanism.
  * `settings/`: App preferences.
  * `splash/`: Splash screen logic.

## 🛠️ Built With

* [Flutter](https://flutter.dev/) - UI Toolkit
* [Riverpod](https://riverpod.dev/) - Reactive State Management
* [Google Sign In](https://pub.dev/packages/google_sign_in) & [Googleapis](https://pub.dev/packages/googleapis) - Authentication & Drive Backup
* [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) - Exporting & Printing
* [share_plus](https://pub.dev/packages/share_plus) - Sharing functionalities

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
