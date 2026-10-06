# Notes App

Notes is a feature-rich, privacy-focused, cross-platform note-taking application built with Flutter. It helps you capture ideas with rich Markdown formatting, organize notes into folders, manage task checklists with an integrated focus timer, lock private notes with a passcode, and back up files to custom storage locations.

## Features

- **Rich Markdown Note Editing**: Create and edit notes with live inline Markdown formatting, headers, lists, blockquotes, tables, and version history snapshots.
- **Task & Checklist Management**: Manage checkable task lists with smart enter continuation, category icons, tags, and an integrated Focus Timer.
- **Folder & Category Organization**: Group notes and task lists into color-coded folders with custom sorting and layout view options.
- **Passcode & Privacy Protection**: Secure sensitive notes and folders with passcode protection (PIN lock).
- **Interactive Calendar View**: View notes and tasks organized by dates on a full-featured calendar interface.
- **Pin & Quick Access**: Pin your most critical notes to the top of your workspace for fast retrieval.
- **Search & Filter**: Instantly search across note titles, contents, tags, and folders.
- **Trash & Item Recovery**: Soft-delete items to the Trash bin with full restore and permanent deletion options.
- **Export, Print & Share**: Export notes as PDFs, images, or print them directly from the app.
- **Storage Setup Wizard**: Choose and configure local database storage and file directory locations.
- **Cross-Platform Responsive Design**: Features responsive desktop sidebars and smooth animations tailored for Desktop (Windows, macOS, Linux), Web, and Mobile.

## Getting Started

### Prerequisites

- Flutter SDK (version ^3.12.2 or higher)
- Dart SDK
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/abinjoyal/MyNotes-App.git
   cd mynotes
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

## Project Architecture

This project follows a feature-driven, clean architecture approach:

- **`lib/app/`**: Application configuration, theme data, navigation router, and global responsive layouts (sidebar layout, desktop layout).
- **`lib/core/`**: Shared infrastructure including SQLite database, local storage services, export service, and extensions.
- **`lib/features/`**: Modular feature directories containing domain models, data sources, and presentation widgets:
  - `notes/`: Note creation, Markdown editor, and version history service.
  - `tasks/`: Task checklist view, focus timer controller, and markdown utilities.
  - `folders/`: Folder CRUD management and folder lock controls.
  - `calendar/`: Calendar screen and event date bindings.
  - `pin/`: Pinning logic and pinned items view.
  - `setup/`: Storage wizard setup screen and passcode-locked notes view.
  - `trash/`: Soft-delete trash management and empty trash workflow.
  - `settings/`: App configuration, font sizes, grid/list toggles, and security settings.
  - `splash/`: Application boot and initialization.

## Built With

- [Flutter](https://flutter.dev/) - Cross-platform UI toolkit
- [Riverpod](https://riverpod.dev/) - Reactive state management
- [sqflite](https://pub.dev/packages/sqflite) & [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) - SQLite local database
- [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) - Document export and printing
- [local_auth](https://pub.dev/packages/local_auth) - Local biometric / passcode authentication
- [flutter_animate](https://pub.dev/packages/flutter_animate) - Micro-animations and transitions

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
