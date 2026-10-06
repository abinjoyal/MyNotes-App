import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/app/theme/app_theme_colors.dart';
import 'package:notes/features/notes/presentation/controllers/notes_provider.dart';
import 'package:notes/features/trash/presentation/widgets/trash_item_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesController = ref.watch(notesProvider);
    final trashedNotes = notesController.trashedNotes;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        Material(
                          color: colors.isDark
                              ? const Color(0xFF1E1E2A)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: colors.textColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Trash Bin',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),

                          Text(
                            'Items in trash can be restored or permanently deleted',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (trashedNotes.isNotEmpty)
                    ElevatedButton(
                      onPressed: () =>
                          _confirmEmptyTrash(context, notesController),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Empty Trash',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Grid / Empty State
            Expanded(
              child: trashedNotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.isDark
                                  ? const Color(0xFF1E1E2A)
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_sweep_outlined,
                              size: 56,
                              color: colors.secondaryTextColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Trash is empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Notes deleted from your workspace will show up here.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            mainAxisExtent: 190,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: trashedNotes.length,
                      itemBuilder: (context, index) {
                        final note = trashedNotes[index];
                        return TrashItemCard(
                              note: note,
                              onRestore: () =>
                                  notesController.restoreFromTrash(note.id),
                              onDelete: () => _confirmDelete(
                                context,
                                notesController,
                                note.id,
                              ),
                            )
                            .animate()
                            .fade(duration: 200.ms, delay: (index * 40).ms)
                            .slideY(begin: 0.05);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    dynamic notesController,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Permanently?'),
        content: const Text(
          'This note will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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

  Future<void> _confirmEmptyTrash(
    BuildContext context,
    dynamic notesController,
  ) async {
    final count = notesController.trashedNotes.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Empty Trash?'),
        content: Text(
          'Are you sure you want to permanently delete $count item${count == 1 ? '' : 's'} from the trash? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
