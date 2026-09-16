import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() => openedAt = DateTime.now();

  String? _cachedReport;

  String buildReport() => _cachedReport ??= displayList.join('\n');

  Iterable<String> get allTitles => items.map((item) => item.title);

  Iterable<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010);

  // fold, а не reduce: reduce падает на пустом списке
  double get averagePages {
    final books = items.whereType<Book>();
    return books.isEmpty
        ? 0
        : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;
  }

  Map<String, int> get bookCountByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        <String, int>{},
            (map, book) => map..update(
          book.author.name,
              (count) => count + 1,
          ifAbsent: () => 1,
        ),
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList {
    final books = items.whereType<Book>().toList();
    final hasIncompleteData = books.any((book) => book.pages == 0);
    return [
      'CATALOGUE',
      for (final book in books) '${book.title} (${book.year})',
      ...authorNames,
      if (hasIncompleteData) '(incomplete data)',
    ];
  }
}