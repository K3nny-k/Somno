import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabaseProvider {
  static const String _dbName = 'somnosense.db';
  static const int _dbVersion = 1;

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbName);
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        final schema = await rootBundle.loadString('assets/schema.sql');
        final statements = schema.split(';');
        for (final stmt in statements) {
          final sql = stmt.trim();
          if (sql.isNotEmpty) {
            await db.execute('$sql;');
          }
        }
      },
    );
  }
}

