// lib/core/router.dart
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/daily_screen.dart';
import '../screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.routeSplash,
  routes: [
    GoRoute(
      path: AppConstants.routeSplash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppConstants.routeHome,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: AppConstants.routeGame,
      builder: (_, __) => const GameScreen(),
    ),
    GoRoute(
      path: AppConstants.routeDaily,
      builder: (_, __) => const DailyScreen(),
    ),
    GoRoute(
      path: AppConstants.routeProfile,
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);
