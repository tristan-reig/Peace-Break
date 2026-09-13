import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../game_state.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({super.key, required this.state, required this.onPause});

  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.black54,
        child: Row(
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
            const Spacer(),
            _stat(Icons.star, '${state.score}'),
            const SizedBox(width: 12),
            _stat(Icons.monetization_on, '${state.coins}'),
            const SizedBox(width: 12),
            Row(
              children: List.generate(
                state.lives.clamp(0, 5),
                (_) => const Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.redAccent,
                ),
              ),
            ),
            if (state.lives > 5)
              Text(' x${state.lives}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
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
