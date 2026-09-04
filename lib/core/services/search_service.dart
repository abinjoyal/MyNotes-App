import '../../../features/notes/domain/entities/note.dart';

class SearchService {
  static final SearchService instance = SearchService._internal();
  factory SearchService() => instance;
  SearchService._internal();

  /// Filters notes matching query and tag
  List<Note> filterNotes(
    List<Note> notes, {
    String query = '',
    String? selectedTag,
  }) {
    final lowerQuery = query.toLowerCase().trim();

    return notes.where((note) {
      final matchesQuery = lowerQuery.isEmpty ||
          note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      final matchesTag = selectedTag == null || note.tags.contains(selectedTag);

      return matchesQuery && matchesTag;
    }).toList();
  }

  /// Sorts notes according to sortOption ('Last edited', 'Title', 'Date created')
  List<Note> sortNotes(List<Note> notes, String sortOption) {
    final sortedList = List<Note>.from(notes);

    switch (sortOption) {
      case 'Title':
        sortedList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Date created':
        sortedList.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'Last edited':
      default:
        sortedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return sortedList;
  }
}
