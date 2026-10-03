import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynotes/app/theme/app_theme_colors.dart';
import 'package:mynotes/features/trash/presentation/controllers/trash_provider.dart';
import 'package:mynotes/features/trash/presentation/widgets/trash_item_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashController = ref.watch(trashProvider);
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
                      '${trashController.items.length} items in trash',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                if (trashController.items.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _confirmEmptyTrash(context, trashController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            child: trashController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : trashController.items.isEmpty
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
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: trashController.items.length,
                        itemBuilder: (context, index) {
                          final item = trashController.items[index];
                          return TrashItemCard(
                            item: item,
                            onRestore: () => trashController.restoreNote(item.note.id),
                            onDelete: () => _confirmDelete(context, trashController, item.note.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, trashController, String id) async {
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
      trashController.deletePermanently(id);
    }
  }

  Future<void> _confirmEmptyTrash(BuildContext context, trashController) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text('All items in the trash will be permanently deleted.'),
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
      trashController.emptyTrash();
    }
  }
}
