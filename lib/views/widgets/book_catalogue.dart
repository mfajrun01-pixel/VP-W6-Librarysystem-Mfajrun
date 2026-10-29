import 'package:flutter/material.dart';
import '/viewmodels/library_view_model.dart';
import '/views/widgets/book_card.dart';
import '/views/widgets/empty_state.dart';
import '/views/widgets/fine_summary_card.dart';
import '/views/widgets/search_filter_bar.dart';

class BookCatalogue extends StatelessWidget {
  final LibraryViewModel viewModel;
  final TextEditingController searchController;
  final Function(dynamic) onBorrowPressed;

  const BookCatalogue({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onBorrowPressed,
  });

  @override
  Widget build(BuildContext context) {
    final books = viewModel.filteredBooks;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FineSummaryCard(viewModel: viewModel)),
        SliverToBoxAdapter(
          child: SearchFilterBar(
            viewModel: viewModel,
            searchController: searchController,
          ),
        ),
        if (books.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              message: 'No books found.',
            ),
          )
        else
          SliverList.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                onBorrowPressed: () => onBorrowPressed(book),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}