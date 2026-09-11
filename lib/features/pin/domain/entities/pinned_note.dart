class PinnedNote {
  final String id;
  final String noteId;
  final DateTime pinnedAt;

  const PinnedNote({
    required this.id,
    required this.noteId,
    required this.pinnedAt,
  });

  PinnedNote copyWith({
    String? id,
    String? noteId,
    DateTime? pinnedAt,
  }) {
    return PinnedNote(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }
}
