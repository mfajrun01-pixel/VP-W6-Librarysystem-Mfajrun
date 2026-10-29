import 'package:flutter/material.dart';

class LibraryHeader extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const LibraryHeader({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'University Library',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 2,
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(icon: Icon(Icons.library_books)),
          Tab(icon: Icon(Icons.assignment)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}