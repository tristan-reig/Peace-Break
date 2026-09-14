import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../game_state.dart';
import '../power_up.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
    required this.state,
    required this.onPause,
    required this.activePowers,
  });

  final GameState state;
  final VoidCallback onPause;

  final Map<PowerType, double> Function() activePowers;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final powers = activePowers();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.black54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause_circle, size: 30),
                    color: AppTheme.accent,
                    onPressed: onPause,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Stage ${state.stage}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  _Timer(seconds: state.secondsLeft),
                  const Spacer(),
                  _stat(Icons.star, '${state.score}'),
                  const SizedBox(width: 12),
                  _stat(Icons.monetization_on, '${state.coins}'),
                  const SizedBox(width: 12),
                  _Lives(lives: state.lives),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 20,
                child: powers.isEmpty
                    ? null
                    : Row(
                        children: powers.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  entry.key.icon,
                                  size: 14,
                                  color: entry.key.color,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${entry.value.ceil()}s',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppTheme.accent),
      const SizedBox(width: 3),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

class _Timer extends StatelessWidget {
  const _Timer({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          size: 16,
          color: urgent ? Colors.redAccent : Colors.white70,
        ),
        const SizedBox(width: 3),
        Text(
          '$m:$s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: urgent ? Colors.redAccent : null,
          ),
        ),
      ],
    );
  }
}

class _Lives extends StatelessWidget {
  const _Lives({required this.lives});
  final int lives;

  @override
  Widget build(BuildContext context) {
    if (lives > 5) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
          const SizedBox(width: 3),
          Text('×$lives', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        lives.clamp(0, 5),
        (_) => const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
      ),
    );
  }
}
