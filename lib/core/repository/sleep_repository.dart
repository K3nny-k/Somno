import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';

class SleepEpisode {
  final int? id;
  final DateTime dateLocal;
  final DateTime onset;
  final DateTime wake;
  final int durationMin;
  final double? efficiency;
  final String? source;
  final double? confidence;
  final String? featuresJson;
  final bool edited;

  SleepEpisode({
    this.id,
    required this.dateLocal,
    required this.onset,
    required this.wake,
    required this.durationMin,
    this.efficiency,
    this.source,
    this.confidence,
    this.featuresJson,
    this.edited = false,
  });

  Map<String, Object?> toRow() => {
        if (id != null) 'id': id,
        'date_local': _ymd(dateLocal),
        'onset_ts': onset.millisecondsSinceEpoch,
        'wake_ts': wake.millisecondsSinceEpoch,
        'duration_min': durationMin,
        'efficiency': efficiency,
        'source': source,
        'confidence': confidence,
        'features_json': featuresJson,
        'edited': edited ? 1 : 0,
      };

  static SleepEpisode fromRow(Map<String, Object?> row) => SleepEpisode(
        id: row['id'] as int?,
        dateLocal: DateTime.parse(row['date_local'] as String),
        onset: DateTime.fromMillisecondsSinceEpoch(row['onset_ts'] as int),
        wake: DateTime.fromMillisecondsSinceEpoch(row['wake_ts'] as int),
        durationMin: row['duration_min'] as int,
        efficiency: (row['efficiency'] as num?)?.toDouble(),
        source: row['source'] as String?,
        confidence: (row['confidence'] as num?)?.toDouble(),
        featuresJson: row['features_json'] as String?,
        edited: (row['edited'] as int? ?? 0) == 1,
      );
}

class SleepRepository {
  Future<int> upsert(SleepEpisode ep) async {
    final db = await AppDatabaseProvider.database;
    return db.insert('sleep_episode', ep.toRow(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SleepEpisode>> listRecent({int days = 30}) async {
    final db = await AppDatabaseProvider.database;
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await db.query(
      'sleep_episode',
      where: 'date_local >= ?',
      whereArgs: [_ymd(since)],
      orderBy: 'date_local DESC',
    );
    return rows.map(SleepEpisode.fromRow).toList();
  }

  Future<void> deleteAll() async {
    final db = await AppDatabaseProvider.database;
    await db.delete('sleep_episode');
  }

  Future<double> irregularityStddevMinutes({int days = 14}) async {
    final eps = await listRecent(days: days);
    if (eps.length < 2) return 0;
    final minutes = eps
        .map((e) => e.onset.hour * 60 + e.onset.minute)
        .toList();
    final mean = minutes.reduce((a, b) => a + b) / minutes.length;
    final variance = minutes.map((m) => (m - mean) * (m - mean)).reduce((a, b) => a + b) / (minutes.length - 1);
    return variance.abs().sqrt();
  }
}

extension on num {
  double sqrt() => MathHelper.sqrt(toDouble());
}

class MathHelper {
  static double sqrt(double x) {
    double guess = x / 2.0;
    for (int i = 0; i < 10; i++) {
      if (guess == 0) return 0;
      guess = 0.5 * (guess + x / guess);
    }
    return guess;
  }
}

String _ymd(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;

