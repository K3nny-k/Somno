import 'package:flutter/material.dart';
import '../../core/repository/profile_repository.dart';
import '../../core/repository/sleep_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _age;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _age = await ProfileRepository().getAgeBand();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Age band: ${_age ?? '-'}'),
        const SizedBox(height: 8),
        const Text('Privacy: mic off by default (placeholder)'),
        const SizedBox(height: 16),
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              // Export DB placeholder
              final messenger = ScaffoldMessenger.of(ctx);
              messenger.showSnackBar(
                const SnackBar(content: Text('Export requested (placeholder)')),
              );
            },
            child: const Text('Export Data'),
          );
        }),
        const SizedBox(height: 8),
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              await SleepRepository().deleteAll();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Deleted all sleep episodes')),
              );
            },
            child: const Text('Delete All Sleep Episodes'),
          );
        })
      ],
    );
  }
}

