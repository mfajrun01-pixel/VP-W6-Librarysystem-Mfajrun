import 'package:flutter/material.dart';
import '../../viewmodels/library_view_model.dart';

class FineSummaryCard extends StatelessWidget {
  final LibraryViewModel viewModel;

  const FineSummaryCard({
    super.key,
    required this.viewModel,
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
    final activeLoans = viewModel.activeLoans;
    final totalFines = viewModel.totalOutstandingFines;

    int overdueCount = 0;
    int missingCount = 0;

    for (final loan in activeLoans) {
      final status = viewModel.getLoanStatus(loan);
      if (status == LoanStatus.overdue) overdueCount++;
      if (status == LoanStatus.missing) missingCount++;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fine Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: totalFines > 0
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatCurrency(totalFines),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: totalFines > 0 ? Colors.red : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  label: 'Active Loans',
                  value: '${activeLoans.length}',
                  icon: Icons.book,
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Overdue',
                  value: '$overdueCount',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange[800]!,
                ),
                _buildSummaryItem(
                  context,
                  label: 'Missing',
                  value: '$missingCount',
                  icon: Icons.error_outline,
                  color: Colors.red[800]!,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                'Overdue Test Simulation Helper',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ActionChip(
                      label: const Text('Normal (Now)'),
                      onPressed: () => viewModel.setSimulatedCurrentDate(null),
                    ),
                    ActionChip(
                      label: const Text('+7 Days (1 Wk Overdue)'),
                      onPressed: () {
                        if (viewModel.loans.isNotEmpty) {
                          final loan = viewModel.loans.last;
                          viewModel.setSimulatedCurrentDate(
                              loan.dueDate.add(const Duration(days: 7)));
                        }
                      },
                    ),
                    ActionChip(
                      label: const Text('+14 Days (2 Wks Overdue)'),
                      onPressed: () {
                        if (viewModel.loans.isNotEmpty) {
                          final loan = viewModel.loans.last;
                          viewModel.setSimulatedCurrentDate(
                              loan.dueDate.add(const Duration(days: 14)));
                        }
                      },
                    ),
                    ActionChip(
                      label: const Text('+6 Months (Missing)'),
                      onPressed: () {
                        if (viewModel.loans.isNotEmpty) {
                          final loan = viewModel.loans.last;
                          final d = loan.dueDate;
                          viewModel.setSimulatedCurrentDate(
                              DateTime(d.year, d.month + 6, d.day + 1));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
