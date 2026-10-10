import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<TransactionModel> insertTransaction(
    TransactionModel transaction,
  ) async {
    final db = await _appDatabase.database;

    final id = await db.insert(
      AppDatabase.transactionsTable,
      transaction.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return TransactionModel(
      id: id,
      title: transaction.title,
      amount: transaction.amount,
      category: transaction.category,
      date: transaction.date,
      description: transaction.description,
      type: transaction.type,
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      AppDatabase.transactionsTable,
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    final id = transaction.id;

    if (id == null) {
      throw ArgumentError('Cannot update a transaction without an ID.');
    }

    final db = await _appDatabase.database;

    final updatedRows = await db.update(
      AppDatabase.transactionsTable,
      transaction.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );

    return updatedRows > 0;
  }

  Future<bool> deleteTransaction(int id) async {
    final db = await _appDatabase.database;

    final deletedRows = await db.delete(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    return deletedRows > 0;
  }
}
