import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/profile_controller.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Peace Break',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 24),

              if (controller.loading && profile == null)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.error != null && profile == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.error!),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: controller.load,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (profile != null) ...[
                _StatsCard(
                  username: profile.username,
                  totalScore: profile.totalScore,
                  coins: profile.coins,
                  nextStage: profile.nextStage,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.game),
                  child: Text('Jouer — stage ${profile.nextStage}'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'Stages complétés',
                  route: Routes.stages,
                ),
                _MenuButton(label: 'Boutique', route: Routes.shop),
                _MenuButton(label: 'Inventaire', route: Routes.inventory),
                _MenuButton(label: 'Top 10', route: Routes.leaderboard),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings, size: 32),
                  tooltip: 'Réglages',
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.settings),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.username,
    required this.totalScore,
    required this.coins,
    required this.nextStage,
  });

  final String username;
  final int totalScore;
  final int coins;
  final int nextStage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _row(Icons.star, 'Score total', '$totalScore'),
            _row(Icons.monetization_on, 'Pièces', '$coins'),
            _row(Icons.flag, 'Prochain stage', '$nextStage'),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accent),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.route});
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(label),
      ),
    );
  }
}
