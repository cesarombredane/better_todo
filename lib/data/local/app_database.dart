import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'better_todo.db';
  static const _version = 1;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final directory = await getDatabasesPath();

    return openDatabase(path.join(directory, _fileName), version: _version);
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) return;

    await database.close();
    _database = null;
  }
}
