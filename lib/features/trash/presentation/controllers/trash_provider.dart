import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/database/database.dart';
import '../../data/repositories/trash_repository_impl.dart';
import '../../domain/usecases/get_trash_items.dart';
import '../../domain/usecases/restore_note.dart';
import '../../domain/usecases/delete_permanently.dart';
import '../../domain/usecases/empty_trash.dart';
import 'trash_controller.dart';

final trashProvider = ChangeNotifierProvider<TrashController>((ref) {
  final repository = TrashRepositoryImpl(AppDatabase.instance);
  
  return TrashController(
    getTrashItemsUseCase: GetTrashItemsUseCase(repository),
    restoreNoteUseCase: RestoreNoteUseCase(repository),
    deleteNotePermanentlyUseCase: DeleteNotePermanentlyUseCase(repository),
    emptyTrashUseCase: EmptyTrashUseCase(repository),
  );
});
