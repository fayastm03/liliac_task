
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/transaction_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  static const Color _teal = Color(0xFF2F817C);
  static const Color _green = Color(0xFF16B364);
  static const Color _red = Color(0xFFFF514D);
  static const Color _muted = Color(0xFF737373);

  Future<void> _openEditTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);

    if (transactionDay == today) return 'Today';

    if (transactionDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    return '${_month(date.month)} ${date.day}, ${date.year}';
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // Total expenses from the last 7 calendar days, including today,
  // divided by 7 to calculate the daily average.
  double _averagePerDay(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));
    final endDate = today.add(const Duration(days: 1));

    final weeklyTotal = transactions
        .where((transaction) {
          return transaction.type == 'expense' &&
              !transaction.date.isBefore(startDate) &&
              transaction.date.isBefore(endDate);
        })
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );

    return weeklyTotal / 7;
  }

  // Actual expenses from the last 7 calendar days, including today.
  double _averagePerWeek(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));
    final endDate = today.add(const Duration(days: 1));

    return transactions
        .where((transaction) {
          return transaction.type == 'expense' &&
              !transaction.date.isBefore(startDate) &&
              transaction.date.isBefore(endDate);
        })
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;
    final recentTransactions = transactions.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadTransactions,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              const Text(
                'Good afternoon,',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 3),
              const Text(
                'Sahal Muhammed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),

              // Total balance card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹ ${_formatAmount(provider.balance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceItem(
                            icon: Icons.arrow_downward,
                            label: 'Income',
                            amount: provider.totalIncome,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBalanceItem(
                            icon: Icons.arrow_upward,
                            label: 'Expenses',
                            amount: provider.totalExpenses,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Daily average and weekly expense cards
              Row(
                children: [
                  Expanded(
                    child: _buildAverageCard(
                      label: 'DAILY AVERAGE',
                      amount: _averagePerDay(transactions),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAverageCard(
                      label: 'WEEKLY',
                      amount: _averagePerWeek(transactions),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent transaction heading
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transactions History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSeeAll,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              if (provider.isLoading && transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null &&
                  transactions.isEmpty)
                _buildErrorState(
                  provider.errorMessage!,
                  provider.loadTransactions,
                )
              else if (recentTransactions.isEmpty)
                _buildEmptyState()
              else
                ...recentTransactions.map(
                  (transaction) =>
                      _buildTransactionRow(context, transaction),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required double amount,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '₹ ${_formatAmount(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAverageCard({
    required String label,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFDADADA),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹ ${_formatAmount(amount)}',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final isIncome = transaction.type == 'income';

    return InkWell(
      onTap: () => _openEditTransaction(context, transaction),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : '-'} ₹ ${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isIncome ? _green : _red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Text(
        'No transactions yet. Tap + to add your first transaction.',
        style: TextStyle(
          fontSize: 14,
          color: _muted,
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    Future<void> Function() retry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        TextButton(
          onPressed: retry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
