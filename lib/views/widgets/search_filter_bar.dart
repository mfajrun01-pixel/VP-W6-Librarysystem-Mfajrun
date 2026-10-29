import 'package:flutter/material.dart';
import '/viewmodels/library_view_model.dart';

class SearchFilterBar extends StatelessWidget {
  final LibraryViewModel viewModel;
  final TextEditingController searchController;

  const SearchFilterBar({
    super.key,
    required this.viewModel,
    required this.searchController,
  });

  String _label(BookFilter filter) {
    switch (filter) {
      case BookFilter.all:
        return 'All';
      case BookFilter.available:
        return 'Available';
      case BookFilter.borrowed:
        return 'Borrowed';
      case BookFilter.overdue:
        return 'Overdue';
      case BookFilter.missing:
        return 'Missing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          ListenableBuilder(
            listenable: searchController,
            builder: (context, _) {
              return TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title, author, ID, student...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      viewModel.setSearchQuery('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: viewModel.setSearchQuery,
              );
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BookFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_label(filter)),
                    selected: viewModel.selectedFilter == filter,
                    onSelected: (_) => viewModel.setFilter(filter),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
