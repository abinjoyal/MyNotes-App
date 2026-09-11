import 'package:flutter/material.dart';
import 'route_names.dart';
import '../layout/responsive_layout.dart';
import '../layout/desktop_layout.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/widgets/search_screen.dart';
import '../../features/trash/presentation/screens/trash_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/pin/presentation/screens/pinned_notes_screen.dart';
import '../../features/folders/presentation/screens/folders_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/pin/data/datasources/pin_local_datasource.dart';
import '../../features/pin/data/repositories/pin_repository_impl.dart';
import '../../features/pin/domain/usecases/get_pinned_notes.dart';
import '../../features/pin/domain/usecases/pin_note_usecase.dart';
import '../../features/pin/domain/usecases/unpin_note_usecase.dart';
import '../../features/pin/presentation/controllers/pin_controller.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.initial:
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const ResponsiveLayout(
            mobile: NotesScreen(),
            desktop: DesktopLayout(),
          ),
        );

      case RouteNames.createNote:
      case RouteNames.noteEditor:
        return MaterialPageRoute(
          builder: (_) => const NoteEditorScreen(),
        );

      case RouteNames.search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );

      case RouteNames.trash:
        return MaterialPageRoute(
          builder: (_) => const TrashScreen(),
        );

      case RouteNames.tasks:
        return MaterialPageRoute(
          builder: (_) => const TasksScreen(),
        );

      case RouteNames.pinned:
        return MaterialPageRoute(
          builder: (_) {
            final localDataSource = PinLocalDataSourceImpl();
            final repository = PinRepositoryImpl(localDataSource);
            final controller = PinController(
              getPinnedNotesUseCase: GetPinnedNotes(repository),
              pinNoteUseCase: PinNoteUseCase(repository),
              unpinNoteUseCase: UnpinNoteUseCase(repository),
            );
            return PinnedNotesScreen(controller: controller);
          },
        );

      case RouteNames.folders:
        return MaterialPageRoute(
          builder: (_) => const FoldersScreen(),
        );

      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
