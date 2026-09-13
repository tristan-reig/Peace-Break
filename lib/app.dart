import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/menu/menu_screen.dart';

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
        Routes.stages: (_) => const PlaceholderScreen('Stages complétés'),
        Routes.game: (_) => const PlaceholderScreen('Jeu'),
        Routes.shop: (_) => const PlaceholderScreen('Shop'),
        Routes.inventory: (_) => const PlaceholderScreen('Inventaire'),
        Routes.leaderboard: (_) => const PlaceholderScreen('Top 10'),
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
    return hasSession
        ? const MenuScreen()
        : const LoginScreen();
  }
}
