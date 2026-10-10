import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({required this._repository});
  final TransactionRepository _repository;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  double get totalExpenses => _transactions
      .where((transaction) => transaction.type == 'expense')
      .fold(0.0, (total, transaction) => total + transaction.amount);

  double get totalIncome => _transactions
      .where((transaction) => transaction.type == 'income')
      .fold(0.0, (total, transaction) => total + transaction.amount);

  double get balance => totalIncome - totalExpenses;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions();
    } catch (error) {
      _errorMessage = 'Unable to load transactions. Please try again.';
      debugPrint('Load transactions failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    _errorMessage = null;

    try {
      await _repository.insertTransaction(transaction);
      await loadTransactions();
      return _errorMessage == null;
    } catch (error) {
      _errorMessage = 'Unable to save the transaction.';
      debugPrint('Add transaction failed: $error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _errorMessage = null;

    try {
      final updated = await _repository.updateTransaction(transaction);

      if (!updated) {
        _errorMessage = 'Transaction not found.';
        notifyListeners();
        return false;
      }

      await loadTransactions();
      return _errorMessage == null;
    } catch (error) {
      _errorMessage = 'Unable to update the transaction.';
      debugPrint('Update transaction failed: $error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    _errorMessage = null;

    try {
      final deleted = await _repository.deleteTransaction(id);

      if (!deleted) {
        _errorMessage = 'Transaction not found.';
        notifyListeners();
        return false;
      }

      await loadTransactions();
      return _errorMessage == null;
    } catch (error) {
      _errorMessage = 'Unable to delete the transaction.';
      debugPrint('Delete transaction failed: $error');
      notifyListeners();
      return false;
    }
  }
}
