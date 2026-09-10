import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
  const FolderModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory FolderModel.fromEntity(Folder folder) {
    return FolderModel(
      id: folder.id,
      name: folder.name,
      color: folder.color,
    );
  }
}
