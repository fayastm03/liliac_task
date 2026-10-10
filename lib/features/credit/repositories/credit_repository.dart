
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../models/credit_model.dart';

class CreditRepository {
  CreditRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<CreditModel> insertCredit(CreditModel credit) async {
    final db = await _appDatabase.database;
    final data = credit.toMap()..remove('id');

    final id = await db.insert(
      AppDatabase.creditEntriesTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return credit.copyWith(id: id);
  }

  Future<List<CreditModel>> getCredits() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      AppDatabase.creditEntriesTable,
      orderBy: 'due_date ASC, id DESC',
    );

    return rows.map(CreditModel.fromMap).toList();
  }

  Future<bool> updateCredit(CreditModel credit) async {
    final id = credit.id;

    if (id == null) {
      throw ArgumentError('A credit ID is required to update an entry.');
    }

    final db = await _appDatabase.database;
    final data = credit.toMap()..remove('id');

    final updatedRows = await db.update(
      AppDatabase.creditEntriesTable,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    return updatedRows > 0;
  }

  Future<bool> deleteCredit(int id) async {
    final db = await _appDatabase.database;

    final deletedRows = await db.delete(
      AppDatabase.creditEntriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    return deletedRows > 0;
  }

  Future<void> clearCredits() async {
    final db = await _appDatabase.database;
    await db.delete(AppDatabase.creditEntriesTable);
  }
}
