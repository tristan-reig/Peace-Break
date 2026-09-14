import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/game/game_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/stages/stages_screen.dart';

class PeaceBreakApp extends StatelessWidget {
  const PeaceBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peace Break',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
      routes: {
        Routes.login: (_) => const LoginScreen(),
        Routes.register: (_) => const RegisterScreen(),
        Routes.menu: (_) => const MenuScreen(),
        Routes.stages: (_) => const StagesScreen(),
        Routes.game: (ctx) {
          final args =
              ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>? ??
              const {};
          return GameScreen(
            stage: args['stage'] as int? ?? 1,
            maxLives: args['maxLives'] as int? ?? 3,
          );
        },
        Routes.shop: (_) => const ShopScreen(),
        Routes.inventory: (_) => const InventoryScreen(),
        Routes.leaderboard: (_) => const LeaderboardScreen(),
        Routes.settings: (_) => const PlaceholderScreen('Réglages'),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    return hasSession ? const MenuScreen() : const LoginScreen();
  }
}
