import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/widgets/arcade.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileController>().load();
    });
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
              const ArcadeTitle('Peace Break', size: 20),
              const SizedBox(height: 22),

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
                        Text(
                          controller.error!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.magenta),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: controller.load,
                          child: const Text('REESSAYER'),
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
                _PlayButton(
                  stage: profile.nextStage,
                  maxLives: profile.maxLives,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ArcadeTile(
                      icon: Icons.storefront,
                      label: 'Shop',
                      color: AppTheme.amber,
                      onTap: () => Navigator.pushNamed(context, Routes.shop),
                    ),
                    ArcadeTile(
                      icon: Icons.inventory_2,
                      label: 'Items',
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.inventory),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ArcadeTile(
                      icon: Icons.grid_view,
                      label: 'Stages',
                      onTap: () => Navigator.pushNamed(context, Routes.stages),
                    ),
                    ArcadeTile(
                      icon: Icons.leaderboard,
                      label: 'Top 10',
                      color: AppTheme.cyan,
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.leaderboard),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.settings, size: 28),
                    color: AppTheme.textDim,
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
    return ArcadeFrame(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppTheme.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  username.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.titleFont,
                    fontSize: 10,
                    color: AppTheme.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Counter(
                  label: 'SCORE',
                  value: totalScore,
                  color: AppTheme.green,
                ),
              ),
              Container(width: 2, height: 32, color: AppTheme.greenDim),
              Expanded(
                child: _Counter(
                  label: 'COINS',
                  value: coins,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.titleFont,
            fontSize: 7,
            color: AppTheme.textDim,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString().padLeft(6, '0'),
          style: AppTheme.title(13, color: color),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.stage, required this.maxLives});

  final int stage;
  final int maxLives;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          Routes.game,
          arguments: {'stage': stage, 'maxLives': maxLives},
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.panel,
            border: Border.all(color: AppTheme.green, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BlinkingText(
                'PRESS START',
                style: TextStyle(
                  fontFamily: AppTheme.titleFont,
                  fontSize: 16,
                  color: AppTheme.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'STAGE ${stage.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontFamily: AppTheme.titleFont,
                  fontSize: 8,
                  color: AppTheme.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
