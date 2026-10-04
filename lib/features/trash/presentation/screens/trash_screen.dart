import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynotes/app/theme/app_theme_colors.dart';
import 'package:mynotes/features/notes/presentation/controllers/notes_provider.dart';
import 'package:mynotes/features/trash/presentation/widgets/trash_item_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesController = ref.watch(notesProvider);
    final trashedNotes = notesController.trashedNotes;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (Navigator.canPop(context)) ...[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.textColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trash',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: colors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${trashedNotes.length} item${trashedNotes.length == 1 ? '' : 's'} in trash',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (trashedNotes.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _confirmEmptyTrash(context, notesController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Empty Trash'),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: trashedNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 80,
                          color: colors.secondaryTextColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Trash is empty',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: trashedNotes.length,
                    itemBuilder: (context, index) {
                      final note = trashedNotes[index];
                      return TrashItemCard(
                        note: note,
                        onRestore: () =>
                            notesController.restoreFromTrash(note.id),
                        onDelete: () =>
                            _confirmDelete(context, notesController, note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    notesController,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notesController.permanentlyDeleteFromTrash(id);
    }
  }

  Future<void> _confirmEmptyTrash(BuildContext context, notesController) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text(
          'All items in the trash will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notesController.emptyTrash();
    }
  }
}
