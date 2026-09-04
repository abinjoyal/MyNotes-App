import 'package:flutter/material.dart';
import 'sidebar_layout.dart';
import '../constants/app_colors.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';

class DesktopLayout extends StatefulWidget {
  final Widget? notesListWidget;
  final Widget? editorWidget;

  const DesktopLayout({
    super.key,
    this.notesListWidget,
    this.editorWidget,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  String _activeRoute = 'all_notes';

  Widget _buildMiddlePane() {
    if (widget.notesListWidget != null) {
      return widget.notesListWidget!;
    }
    if (_activeRoute == 'all_notes') {
      return const NotesScreen();
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Active Section: ${_activeRoute.toUpperCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          SidebarLayout(
            activeRoute: _activeRoute,
            onNavigate: (route) {
              setState(() {
                _activeRoute = route;
              });
            },
          ),

          // Divider
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),

          // Main View (Full Width Notes Screen or Split View with Editor)
          Expanded(
            child: widget.editorWidget != null
                ? Row(
                    children: [
                      // Middle Pane (Notes List)
                      Expanded(
                        flex: 2,
                        child: _buildMiddlePane(),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.divider,
                      ),
                      // Right Pane (Note Editor)
                      Expanded(
                        flex: 3,
                        child: widget.editorWidget!,
                      ),
                    ],
                  )
                : _buildMiddlePane(),
          ),
        ],
      ),
    );
  }
}

