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
          decoration: const BoxDecoration(
            color: Color(0xCC000000),
            border: Border(
              bottom: BorderSide(color: AppTheme.greenDim, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause_circle, size: 28),
                    color: AppTheme.green,
                    onPressed: onPause,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ST.${state.stage.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontFamily: AppTheme.titleFont,
                      fontSize: 9,
                      color: AppTheme.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Timer(seconds: state.secondsLeft),
                  const Spacer(),
                  _stat(Icons.star, '${state.score}'),
                  const SizedBox(width: 10),
                  _stat(Icons.monetization_on, '${state.coins}'),
                  const SizedBox(width: 10),
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
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
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
      Icon(icon, size: 15, color: AppTheme.amber),
      const SizedBox(width: 3),
      Text(
        value.padLeft(5, '0'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppTheme.text,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class _Timer extends StatelessWidget {
  const _Timer({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    final color = urgent ? AppTheme.magenta : AppTheme.text;
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: 15, color: color),
        const SizedBox(width: 3),
        Text(
          '$m:$s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
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
          const Icon(Icons.favorite, size: 15, color: AppTheme.magenta),
          const SizedBox(width: 3),
          Text(
            '×$lives',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.text,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        lives.clamp(0, 5),
        (_) => const Padding(
          padding: EdgeInsets.only(left: 1),
          child: Icon(Icons.favorite, size: 15, color: AppTheme.magenta),
        ),
      ),
    );
  }
}
