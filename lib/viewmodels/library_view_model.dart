import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/repositories/book_repository.dart';

enum LoanStatus { active, overdue, missing, returned }

enum BookFilter { all, available, borrowed, overdue, missing }

class LibraryViewModel extends ChangeNotifier {
  final BookRepository _bookRepository;

  final List<Loan> _loans = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  BookFilter _selectedFilter = BookFilter.all;

  DateTime? _simulatedCurrentDate;

  LibraryViewModel({BookRepository? bookRepository})
      : _bookRepository = bookRepository ?? BookRepository();

  List<Book> get books => _bookRepository.books;
  List<Loan> get loans => List.unmodifiable(_loans);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  BookFilter get selectedFilter => _selectedFilter;
  DateTime get currentDate => _simulatedCurrentDate ?? DateTime.now();

  Future<void> loadBooks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _bookRepository.getBooks();
    } catch (e) {
      _errorMessage = 'Failed to load books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(BookFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSimulatedCurrentDate(DateTime? date) {
    _simulatedCurrentDate = date;
    notifyListeners();
  }

  DateTime _missingDateOf(DateTime dueDate) => DateTime(
    dueDate.year,
    dueDate.month + 6,
    dueDate.day,
    dueDate.hour,
    dueDate.minute,
    dueDate.second,
  );

  bool isSixMonthsOverdue(DateTime dueDate, [DateTime? asOfDate]) {
    final effectiveDate = asOfDate ?? currentDate;
    return !effectiveDate.isBefore(_missingDateOf(dueDate));
  }

  double calculateFine(Loan loan, [DateTime? asOfDate]) {
    const double baseRate = 5000.0;

    final effectiveDate = loan.returnDate ?? asOfDate ?? currentDate;

    if (!effectiveDate.isAfter(loan.dueDate)) return 0.0;

    final missingDate = _missingDateOf(loan.dueDate);
    final isMissing = !effectiveDate.isBefore(missingDate);
    final fineEndDate = isMissing ? missingDate : effectiveDate;
    final overdueDays =
    (fineEndDate.difference(loan.dueDate).inHours / 24).ceil();

    final fullWeeks = overdueDays ~/ 7;
    final remainingDays = overdueDays % 7;
    final fullWeeksFine = 7 * baseRate * (fullWeeks * (fullWeeks + 1) / 2);
    final remainingFine = remainingDays * baseRate * (fullWeeks + 1);
    final totalFine = fullWeeksFine + remainingFine;

    if (isMissing) {
      final book = _bookRepository.getBookById(loan.bookId);
      return totalFine + (book?.replacementPrice ?? 150000.0);
    }

    return totalFine;
  }

  LoanStatus getLoanStatus(Loan loan, [DateTime? asOfDate]) {
    final effectiveDate = loan.returnDate ?? asOfDate ?? currentDate;

    if (loan.isReturned) {
      return LoanStatus.returned;
    }

    if (isSixMonthsOverdue(loan.dueDate, effectiveDate)) {
      return LoanStatus.missing;
    }

    if (effectiveDate.isAfter(loan.dueDate)) {
      return LoanStatus.overdue;
    }

    return LoanStatus.active;
  }

  bool borrowBook({
    required String bookId,
    required String studentId,
    DateTime? borrowDate,
    int durationDays = 14,
  }) {
    _errorMessage = '';

    final book = _bookRepository.getBookById(bookId);
    if (book == null) {
      _errorMessage = 'Book not found';
      notifyListeners();
      return false;
    }

    if (!book.isAvailable) {
      _errorMessage =
      'Book "${book.title}" is currently not available for borrowing.';
      notifyListeners();
      return false;
    }

    final hasActiveLoan =
    _loans.any((loan) => loan.bookId == bookId && !loan.isReturned);
    if (hasActiveLoan) {
      _errorMessage = 'Book already has an active borrowing record.';
      notifyListeners();
      return false;
    }

    final now = borrowDate ?? currentDate;
    final dueDate = now.add(Duration(days: durationDays));

    final newLoan = Loan(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      studentId: studentId,
      borrowDate: now,
      dueDate: dueDate,
    );

    _loans.add(newLoan);
    _bookRepository.updateBookAvailability(bookId, false);
    notifyListeners();
    return true;
  }

  bool returnBook(String loanId, [DateTime? returnDate]) {
    _errorMessage = '';
    final loanIndex = _loans.indexWhere((l) => l.id == loanId);

    if (loanIndex == -1) {
      _errorMessage = 'Loan record not found';
      notifyListeners();
      return false;
    }

    final loan = _loans[loanIndex];
    if (loan.isReturned) {
      _errorMessage = 'Book is already returned';
      notifyListeners();
      return false;
    }

    final actualReturnDate = returnDate ?? currentDate;
    final updatedLoan = loan.copyWith(returnDate: actualReturnDate);
    _loans[loanIndex] = updatedLoan;

    _bookRepository.updateBookAvailability(loan.bookId, true);

    notifyListeners();
    return true;
  }

  double get totalOutstandingFines {
    return _loans
        .where((loan) => !loan.isReturned)
        .fold(0.0, (sum, loan) => sum + calculateFine(loan));
  }

  List<Loan> get activeLoans {
    return _loans.where((loan) => !loan.isReturned).toList();
  }

  List<Book> get filteredBooks {
    return books.where((book) {
      final matchesQuery = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesQuery) return false;

      final activeLoan = _loans.firstWhere(
            (l) => l.bookId == book.id && !l.isReturned,
        orElse: () => Loan(
          id: '',
          bookId: '',
          studentId: '',
          borrowDate: DateTime.now(),
          dueDate: DateTime.now(),
        ),
      );

      final hasActiveLoan = activeLoan.id.isNotEmpty;
      final loanStatus = hasActiveLoan ? getLoanStatus(activeLoan) : null;

      switch (_selectedFilter) {
        case BookFilter.all:
          return true;
        case BookFilter.available:
          return book.isAvailable;
        case BookFilter.borrowed:
          return !book.isAvailable && loanStatus == LoanStatus.active;
        case BookFilter.overdue:
          return !book.isAvailable && loanStatus == LoanStatus.overdue;
        case BookFilter.missing:
          return !book.isAvailable && loanStatus == LoanStatus.missing;
      }
    }).toList();
  }

  List<Loan> get filteredLoans {
    return _loans.where((loan) {
      final book = _bookRepository.getBookById(loan.bookId);
      final matchesQuery = _searchQuery.isEmpty ||
          loan.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (book != null &&
              book.title.toLowerCase().contains(_searchQuery.toLowerCase()));

      if (!matchesQuery) return false;

      final status = getLoanStatus(loan);

      switch (_selectedFilter) {
        case BookFilter.all:
          return true;
        case BookFilter.available:
          return false;
        case BookFilter.borrowed:
          return status == LoanStatus.active;
        case BookFilter.overdue:
          return status == LoanStatus.overdue;
        case BookFilter.missing:
          return status == LoanStatus.missing;
      }
    }).toList();
  }

  Book? getBookById(String bookId) => _bookRepository.getBookById(bookId);
}