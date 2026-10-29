import 'package:flutter/material.dart';
import '../../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onBorrowPressed;

  const BookCard({
    super.key,
    required this.book,
    required this.onBorrowPressed,
  });

  String _formatCurrency(double amount) {
    final int val = amount.toInt();
    final String str = val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $str';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: book.isAvailable
              ? Colors.green.withOpacity(0.15)
              : Colors.grey.withOpacity(0.2),
          child: Icon(
            Icons.menu_book_rounded,
            color: book.isAvailable ? Colors.green[800] : Colors.grey[700],
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Author: ${book.author}'),
            Text(
              'Replacement Price: ${_formatCurrency(book.replacementPrice)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: book.isAvailable ? onBorrowPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: book.isAvailable
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                foregroundColor: book.isAvailable ? Colors.white : Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(book.isAvailable ? 'Borrow' : 'Borrowed'),
            ),
          ],
        ),
      ),
    );
  }
}
