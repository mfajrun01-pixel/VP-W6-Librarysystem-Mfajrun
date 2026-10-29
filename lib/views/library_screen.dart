import 'package:flutter/material.dart';
import '/models/book.dart';
import '/viewmodels/library_view_model.dart';
import '/views/widgets/book_catalogue.dart';
import '/views/widgets/library_header.dart';
import '/views/widgets/loans.dart';

class LibraryScreen extends StatefulWidget {
  final LibraryViewModel viewModel;

  const LibraryScreen({super.key, required this.viewModel});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.viewModel.loadBooks();
    widget.viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (widget.viewModel.errorMessage.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  void _showBorrowDialog(Book book) {
    final studentIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        void confirm() {
          final studentId = studentIdController.text.trim();
          if (studentId.isEmpty) return;

          Navigator.pop(dialogContext);
          final success = widget.viewModel.borrowBook(
            bookId: book.id,
            studentId: studentId,
          );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully borrowed "${book.title}"'),
                backgroundColor: Colors.green[700],
              ),
            );
          }
        }

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Borrow Book',
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Book: ${book.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'e.g. S12345',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => confirm(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: confirm,
                      child: const Text('Confirm Borrow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onReturn(String loanId, String bookId) {
    final book = widget.viewModel.getBookById(bookId);
    final success = widget.viewModel.returnBook(loanId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Returned "${book?.title ?? 'Book'}". Status updated.'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LibraryHeader(tabController: _tabController),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              BookCatalogue(
                viewModel: widget.viewModel,
                searchController: _searchController,
                onBorrowPressed: (book) => _showBorrowDialog(book),
              ),
              Loans(
                viewModel: widget.viewModel,
                searchController: _searchController,
                onReturnPressed: (loanId, bookId) => _onReturn(loanId, bookId),
              ),
            ],
          );
        },
      ),
    );
  }
}