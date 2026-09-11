import '../../domain/entities/pinned_note.dart';

class PinnedNoteModel extends PinnedNote {
  const PinnedNoteModel({
    required super.id,
    required super.noteId,
    required super.pinnedAt,
  });

  factory PinnedNoteModel.fromJson(Map<String, dynamic> json) {
    return PinnedNoteModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      pinnedAt: DateTime.parse(json['pinnedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'pinnedAt': pinnedAt.toIso8601String(),
    };
  }

  factory PinnedNoteModel.fromEntity(PinnedNote entity) {
    return PinnedNoteModel(
      id: entity.id,
      noteId: entity.noteId,
      pinnedAt: entity.pinnedAt,
    );
  }
}
