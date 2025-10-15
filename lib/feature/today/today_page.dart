import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repository/sleep_repository.dart';
import '../../core/services/forecast_service.dart';
import '../../core/services/coach_service.dart';
import '../../core/services/notification_service.dart';

final forecastProvider = FutureProvider<ForecastResult>((ref) async {
  final repo = SleepRepository();
  final svc = ForecastService(repo);
  return svc.forecastTonight();
});

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(forecastProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        forecastAsync.when(
          data: (f) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tonight's Forecast:"),
              const SizedBox(height: 8),
              Text('P10: ${_fmt(f.bedtimeP10)}'),
              Text('P50: ${_fmt(f.bedtimeP50)}'),
              Text('P90: ${_fmt(f.bedtimeP90)}'),
              Text('Why: ${f.explanation}'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error: $e'),
        ),
        const SizedBox(height: 12),
        FutureBuilder<CoachAction>(
          future: CoachService().pickAction(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Coach Action: ...');
            final a = snapshot.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach Action @21:00', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(a.title, style: Theme.of(context).textTheme.titleLarge),
                    Text(a.description),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await CoachService().logSelection(a);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action logged')));
                            }
                          },
                          child: const Text('I\'ll do this'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () async {
                            await NotificationService().scheduleDailyCoachAtHourMinute(21, 0);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder set for 21:00')));
                            }
                          },
                          child: const Text('Remind me'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text('Last night episode: TBD'),
      ],
    );
  }
}

String _fmt(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

