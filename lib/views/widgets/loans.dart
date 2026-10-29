import 'package:flutter/material.dart';
import '/viewmodels/library_view_model.dart';
import '/views/widgets/empty_state.dart';
import '/views/widgets/fine_summary_card.dart';
import '/views/widgets/loan_card.dart';
import '/views/widgets/search_filter_bar.dart';

class Loans extends StatelessWidget {
  final LibraryViewModel viewModel;
  final TextEditingController searchController;
  final Function(String, String) onReturnPressed;

  const Loans({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onReturnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final loans = viewModel.filteredLoans;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FineSummaryCard(viewModel: viewModel)),
        SliverToBoxAdapter(
          child: SearchFilterBar(
            viewModel: viewModel,
            searchController: searchController,
          ),
        ),
        if (loans.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.assignment_outlined,
              message: 'No borrowing records found.',
            ),
          )
        else
          SliverList.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return LoanCard(
                loan: loan,
                viewModel: viewModel,
                onReturnPressed: () => onReturnPressed(loan.id, loan.bookId),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}