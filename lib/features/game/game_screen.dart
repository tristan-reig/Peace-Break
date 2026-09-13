import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game_state.dart';
import 'peace_break_game.dart';
import 'widgets/game_overlays.dart';
import 'widgets/info_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.stage, required this.maxLives});

  final int stage;
  final int maxLives;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _state = GameState(
    stage: widget.stage,
    maxLives: widget.maxLives,
  );
  late final PeaceBreakGame _game = PeaceBreakGame(state: _state);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _quit() => Navigator.pop(context);

  void _retry() {
    Navigator.pushReplacementNamed(
      context,
      ModalRoute.of(context)!.settings.name!,
      arguments: {'stage': widget.stage, 'maxLives': widget.maxLives},
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _game.togglePause();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              InfoBar(state: _state, onPause: _game.togglePause),
              Expanded(
                child: GameWidget(
                  game: _game,
                  overlayBuilderMap: {
                    'paused': (_, _) => GamePanel(
                      title: 'Pause',
                      children: [
                        ElevatedButton(
                          onPressed: _game.togglePause,
                          child: const Text('Reprendre'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _quit,
                          child: const Text('Quitter'),
                        ),
                      ],
                    ),
                    'won': (_, _) => GamePanel(
                      title: 'Stage réussi !',
                      children: [
                        ScoreLine(label: 'Score', value: '${_state.score}'),
                        ScoreLine(label: 'Pièces', value: '${_state.coins}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _quit,
                          child: const Text('Continuer'),
                        ),
                      ],
                    ),
                    'lost': (_, _) => GamePanel(
                      title: 'Perdu',
                      children: [
                        const Text('Le score n\'est pas enregistré.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retry,
                          child: const Text('Réessayer'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _quit,
                          child: const Text('Menu principal'),
                        ),
                      ],
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
