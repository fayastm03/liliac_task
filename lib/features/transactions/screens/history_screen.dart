import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'transaction_form_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _teal = Color(0xFF2F817C);
  static const Color _green = Color(0xFF16B364);
  static const Color _red = Color(0xFFFF514D);
  static const Color _muted = Color(0xFF737373);

  Future<void> _editTransaction(TransactionModel transaction) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final id = transaction.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete this transaction.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          'Are you sure you want to delete '
          '"${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<TransactionProvider>().deleteTransaction(
      id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Transaction deleted successfully.'
              : 'Could not delete the transaction.',
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final transactions = provider.transactions;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 110,
        centerTitle: true,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        surfaceTintColor: _teal,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 150),
          children: [
            if (provider.isLoading && transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: _teal)),
              )
            else if (provider.errorMessage != null && transactions.isEmpty)
              _buildErrorState(provider)
            else if (transactions.isEmpty)
              _buildEmptyState()
            else
              ...transactions.map(_buildTransactionRow),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(TransactionModel transaction) {
    final isIncome = transaction.type == 'income';

    return Dismissible(
      key: ValueKey(transaction.id ?? transaction.title),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteTransaction(transaction);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: _red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: () => _editTransaction(transaction),
        onLongPress: () => _showTransactionActions(transaction),
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatHistoryDate(transaction.date),
                      style: const TextStyle(fontSize: 13, color: _muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${isIncome ? '+' : '-'} ₹ ${_formatAmount(transaction.amount)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isIncome ? _green : _red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Transaction actions',
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: const Icon(Icons.more_horiz, color: _muted),
                onSelected: (action) {
                  if (action == 'edit') {
                    _editTransaction(transaction);
                  } else if (action == 'delete') {
                    _deleteTransaction(transaction);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: _red, size: 19),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHistoryDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final transactionDate = DateUtils.dateOnly(date);

    if (transactionDate == today) {
      return 'Today';
    }

    if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    return _formatDate(date);
  }

  void _showTransactionActions(TransactionModel transaction) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit transaction'),
              onTap: () {
                Navigator.pop(sheetContext);
                _editTransaction(transaction);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: _red),
              title: const Text('Delete transaction'),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteTransaction(transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFB0B0B0)),
          SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Tap + to add your first transaction.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text('Unable to load transactions.'),
          TextButton(
            onPressed: provider.loadTransactions,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
