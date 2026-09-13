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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text(
                'Peace Break',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              if (controller.loading && profile == null)
                const Expanded(child: Center(child: CircularProgressIndicator()))
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
                _StatsBar(
                  username: profile.username,
                  totalScore: profile.totalScore,
                  coins: profile.coins,
                ),
                const Spacer(),
                _PlayButton(stage: profile.nextStage),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _IconTile(
                      icon: Icons.storefront,
                      label: 'Boutique',
                      route: Routes.shop,
                    ),
                    _IconTile(
                      icon: Icons.backpack,
                      label: 'Inventaire',
                      route: Routes.inventory,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _IconTile(
                      icon: Icons.grid_view,
                      label: 'Stages',
                      route: Routes.stages,
                    ),
                    _IconTile(
                      icon: Icons.emoji_events,
                      label: 'Top 10',
                      route: Routes.leaderboard,
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.settings, size: 30),
                    tooltip: 'Réglages',
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.settings),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau compact : pseudo à gauche, score et pièces à droite.
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.username,
    required this.totalScore,
    required this.coins,
  });

  final String username;
  final int totalScore;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _stat(Icons.star, '$totalScore'),
            const SizedBox(width: 16),
            _stat(Icons.monetization_on, '$coins'),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppTheme.accent),
      const SizedBox(width: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

/// Bouton principal, volontairement plus imposant que les autres.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => Navigator.pushNamed(context, Routes.game),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('JOUER', style: TextStyle(fontSize: 24)),
          Text(
            'Stage $stage',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

/// Grande icône carrée avec libellé, pour la navigation secondaire.
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamed(context, route),
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: Icon(icon, size: 44, color: AppTheme.accent),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
