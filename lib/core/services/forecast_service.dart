import 'dart:math';
import '../repository/sleep_repository.dart';

class ForecastResult {
  final DateTime bedtimeP10;
  final DateTime bedtimeP50;
  final DateTime bedtimeP90;
  final String explanation;
  ForecastResult({
    required this.bedtimeP10,
    required this.bedtimeP50,
    required this.bedtimeP90,
    required this.explanation,
  });
}

class ForecastService {
  final SleepRepository _repo;
  ForecastService(this._repo);

  Future<ForecastResult> forecastTonight() async {
    final history = await _repo.listRecent(days: 14);
    if (history.isEmpty) {
      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day, 23, 0);
      return ForecastResult(
        bedtimeP10: base.subtract(const Duration(minutes: 45)),
        bedtimeP50: base,
        bedtimeP90: base.add(const Duration(minutes: 45)),
        explanation: 'Cold start baseline with ±45 min uncertainty',
      );
    }

    // Simple EMA on bedtime minutes
    double alpha = 0.3;
    double ema = _toMinutes(history.first.onset).toDouble();
    for (final e in history.skip(1)) {
      ema = alpha * _toMinutes(e.onset) + (1 - alpha) * ema;
    }
    final meanMinutes = ema.round();

    // Estimate variability as stddev of last N onset minutes
    final minutes = history.map((e) => _toMinutes(e.onset)).toList();
    final m = minutes.reduce((a, b) => a + b) / minutes.length;
    final variance = minutes.map((v) => pow(v - m, 2)).reduce((a, b) => a + b) / max(1, minutes.length - 1);
    final std = sqrt(variance);

    final p50 = _fromMinutes(meanMinutes);
    final p10 = _fromMinutes((meanMinutes - (std * 1.28)).round());
    final p90 = _fromMinutes((meanMinutes + (std * 1.28)).round());

    return ForecastResult(
      bedtimeP10: p10,
      bedtimeP50: p50,
      bedtimeP90: p90,
      explanation: 'EMA over 14d with variability from recent onset times',
    );
  }

  int _toMinutes(DateTime d) => d.hour * 60 + d.minute;
  DateTime _fromMinutes(int mins) {
    final now = DateTime.now();
    final hour = (mins / 60).floor();
    final minute = mins % 60;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

