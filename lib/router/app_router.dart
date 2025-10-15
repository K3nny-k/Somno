import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../feature/onboarding/age_band_page.dart';
import '../feature/home/home_shell.dart';
import '../core/repository/profile_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final repo = ProfileRepository();
      final age = await repo.getAgeBand();
      final loggingIn = state.matchedLocation == '/onboarding';
      if (age == null && !loggingIn) return '/onboarding';
      if (age != null && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeShell()),
      GoRoute(path: '/onboarding', builder: (c, s) => const AgeBandPage()),
    ],
  );
});

