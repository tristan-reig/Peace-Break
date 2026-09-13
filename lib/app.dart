import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'core/widgets/placeholder_screen.dart';

class PeaceBreakApp extends StatelessWidget {
  const PeaceBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peace Break',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: Routes.menu,
      routes: {
        Routes.login: (_) => const PlaceholderScreen('Login'),
        Routes.register: (_) => const PlaceholderScreen('Register'),
        Routes.menu: (_) => const _TempMenu(),
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

class _TempMenu extends StatelessWidget {
  const _TempMenu();

  @override
  Widget build(BuildContext context) {
    const links = {
      'Login': Routes.login,
      'Stages': Routes.stages,
      'Jeu': Routes.game,
      'Shop': Routes.shop,
      'Inventaire': Routes.inventory,
      'Top 10': Routes.leaderboard,
      'Réglages': Routes.settings,
    };
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Peace Break',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                for (final e in links.entries) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, e.value),
                    child: Text(e.key),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
