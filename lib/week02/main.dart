import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }
  library.open();

  print(library.buildReport());
  print('');

  print('All titles: ${library.allTitles.toList()}');
  print('Books after 2010: '
      '${library.booksAfter2010.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('Distinct authors: ${library.authorNames}');
  print('Genres present: ${library.genresPresent}');
  print('Opened at: ${library.openedAt}');
  print('');

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('Stats record: count=${stats.count}, '
      'avgPages=${stats.avgPages.toStringAsFixed(1)}');

  print('');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('shelf collapsed')));
}