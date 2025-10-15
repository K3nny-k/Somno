import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/repository/profile_repository.dart';

final ageBandProvider = FutureProvider<String?>((ref) async {
  return ProfileRepository().getAgeBand();
});

class AgeBandPage extends ConsumerStatefulWidget {
  const AgeBandPage({super.key});

  @override
  ConsumerState<AgeBandPage> createState() => _AgeBandPageState();
}

class _AgeBandPageState extends ConsumerState<AgeBandPage> {
  String? _selected;

  final List<String> bands = const [
    '<18', '18–24', '25–34', '35–49', '50–64', '65+'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Age Band')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Please choose your age band (required):'),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: _selected,
              items: bands
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _selected = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () async {
                      await ProfileRepository().upsertAgeBand(_selected!);
                      if (context.mounted) context.go('/');
                    },
              child: const Text('Continue'),
            )
          ],
        ),
      ),
    );
  }
}

