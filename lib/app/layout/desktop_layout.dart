import 'package:flutter/material.dart';
import 'sidebar_layout.dart';
import '../constants/app_colors.dart';

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

          // Main View (Notes List + Editor Pane)
          Expanded(
            child: Row(
              children: [
                // Middle Pane (Notes List / Active Screen)
                Expanded(
                  flex: 2,
                  child: widget.notesListWidget ??
                      Container(
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
                      ),
                ),

                const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),

                // Right Pane (Note Editor Preview)
                Expanded(
                  flex: 3,
                  child: widget.editorWidget ??
                      Container(
                        color: const Color(0xFFFAFAFC),
                        child: const Center(
                          child: Text(
                            'Select a note to view or edit',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
