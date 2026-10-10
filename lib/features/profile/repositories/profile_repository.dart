
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

class ProfileRepository {
  ProfileRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Map<String, Object?>> getProfile() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      AppDatabase.profileTable,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isNotEmpty) return rows.first;

    await db.insert(AppDatabase.profileTable, {
      'id': 1,
      'name': 'Sahal Muhammed',
      'photo_path': null,
      'photo_blob': null,
    });

    return (await getProfile());
  }

  Future<void> updateName(String name) async {
    final db = await _appDatabase.database;

    await db.update(
      AppDatabase.profileTable,
      {'name': name},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> updatePhoto(List<int> imageBytes) async {
    final db = await _appDatabase.database;

    await db.update(
      AppDatabase.profileTable,
      {'photo_blob': imageBytes},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> clearPhoto() async {
    final db = await _appDatabase.database;

    await db.update(
      AppDatabase.profileTable,
      {
        'photo_blob': null,
        'photo_path': null,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> clearAllUserData() async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      await txn.delete(AppDatabase.transactionsTable);
      await txn.delete(AppDatabase.creditEntriesTable);

      await txn.update(
        AppDatabase.profileTable,
        {
          'name': 'Sahal Muhammed',
          'photo_path': null,
          'photo_blob': null,
        },
        where: 'id = ?',
        whereArgs: [1],
      );
    });
  }
}
