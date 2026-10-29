import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../viewmodels/library_view_model.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final LibraryViewModel viewModel;
  final VoidCallback onReturnPressed;

  const LoanCard({
    super.key,
    required this.loan,
    required this.viewModel,
    required this.onReturnPressed,
  });

  String _formatCurrency(double amount) {
    final int val = amount.toInt();
    final String str = val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $str';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final book = viewModel.getBookById(loan.bookId);
    final status = viewModel.getLoanStatus(loan);
    final fine = viewModel.calculateFine(loan);

    Color statusColor;
    String statusText;

    switch (status) {
      case LoanStatus.active:
        statusColor = Colors.blue;
        statusText = 'Active';
        break;
      case LoanStatus.overdue:
        statusColor = Colors.orange[800]!;
        statusText = 'Overdue';
        break;
      case LoanStatus.missing:
        statusColor = Colors.red[800]!;
        statusText = 'Missing';
        break;
      case LoanStatus.returned:
        statusColor = Colors.grey[700]!;
        statusText = 'Returned';
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    book?.title ?? 'Unknown Book',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('Student ID: ${loan.studentId}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text('Borrowed: ${_formatDate(loan.borrowDate)}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(loan.dueDate)}',
                      style: TextStyle(
                        fontWeight: status == LoanStatus.overdue ||
                                status == LoanStatus.missing
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: status == LoanStatus.overdue ||
                                status == LoanStatus.missing
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fine Amount:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatCurrency(fine),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: fine > 0 ? Colors.red : Colors.green[800],
                      ),
                    ),
                  ],
                ),
                if (!loan.isReturned)
                  ElevatedButton.icon(
                    onPressed: onReturnPressed,
                    icon: const Icon(Icons.assignment_return, size: 18),
                    label: const Text('Return Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
