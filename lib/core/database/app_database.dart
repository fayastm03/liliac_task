
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'expenzia.db';
  static const int _databaseVersion = 3;

  static const String transactionsTable = 'transactions';
  static const String creditEntriesTable = 'credit_entries';
  static const String profileTable = 'profile';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final directory = await getDatabasesPath();
    final path = join(directory, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTransactionsTable(db);
    await _createCreditEntriesTable(db);
    await _createProfileTable(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createCreditEntriesTable(db);
      await _createProfileTable(db);
    } else if (oldVersion < 3) {
      // Add image storage to existing version 2 profiles.
      await db.execute(
        'ALTER TABLE $profileTable ADD COLUMN photo_blob BLOB',
      );
    }
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL
          CHECK(type IN ('income', 'expense'))
      )
    ''');
  }

  Future<void> _createCreditEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE credit_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        credit_type TEXT NOT NULL,
        recipient TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        due_date TEXT NOT NULL,
        plan_type TEXT NOT NULL
          CHECK(plan_type IN ('Monthly', 'One-Time')),
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        name TEXT NOT NULL,
        photo_path TEXT,
        photo_blob BLOB
      )
    ''');

    await db.insert(profileTable, {
      'id': 1,
      'name': 'Sahal Muhammed',
      'photo_path': null,
      'photo_blob': null,
    });
  }
}
