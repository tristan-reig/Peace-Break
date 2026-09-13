import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'peace_break_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.stage = 1});
  final int stage;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PeaceBreakGame _game = PeaceBreakGame(stage: widget.stage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(
              game: _game,
              overlayBuilderMap: {
                'cleared': (context, PeaceBreakGame game) => Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Stage terminé !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Retour au menu'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
