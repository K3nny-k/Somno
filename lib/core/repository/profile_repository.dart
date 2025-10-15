import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';

class ProfileRepository {
  Future<void> upsertAgeBand(String ageBand) async {
    final db = await AppDatabaseProvider.database;
    await db.insert(
      'profile',
      {
        'user_id': 'local',
        'age_band': ageBand,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getAgeBand() async {
    final db = await AppDatabaseProvider.database;
    final rows = await db.query('profile', where: 'user_id = ?', whereArgs: ['local'], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['age_band'] as String?;
  }
}

