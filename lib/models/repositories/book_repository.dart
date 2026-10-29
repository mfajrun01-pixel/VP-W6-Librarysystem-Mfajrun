import '../book.dart';
import '../loan.dart';
import '../services/book_service.dart';

class BookRepository {
  final BookService _bookService;
  List<Book> _books = [];
  List<Loan> _loans = [];

  BookRepository({BookService? bookService})
      : _bookService = bookService ?? BookService();

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);

  Future<List<Book>> getBooks() async {
    if (_books.isEmpty) {
      _books = await _bookService.loadBooksFromAsset();
    }
    return books;
  }

  Book? getBookById(String bookId) {
    try {
      return _books.firstWhere((book) => book.id == bookId);
    } catch (_) {
      return null;
    }
  }

  void updateBookAvailability(String bookId, bool isAvailable) {
    final index = _books.indexWhere((book) => book.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(isAvailable: isAvailable);
    }
  }

  Future<void> addLoan(Loan loan) async {
    _loans.add(loan);
  }

  Future<bool> returnBook(String loanId) async {
    final index = _loans.indexWhere((loan) => loan.id == loanId);
    if (index != -1) {
      final loan = _loans[index];

      _loans[index] = loan.copyWith(returnDate: DateTime.now());
      updateBookAvailability(loan.bookId, true);

      return true;
    }
    return false;
  }
}