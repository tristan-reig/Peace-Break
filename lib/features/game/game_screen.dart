import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';
import 'peace_break_game.dart';
import 'widgets/game_overlays.dart';
import 'widgets/info_bar.dart';
import '../../services/profile_controller.dart';
import '../../services/stage_service.dart';

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

  StageResult? _result;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _game.onWin = _save;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final result = await StageService().complete(
        stage: widget.stage,
        score: _state.score,
        coins: _state.coins,
      );
      if (!mounted) return;
      setState(() => _result = result);
      await context.read<ProfileController>().load();
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = 'Sauvegarde impossible. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                        ScoreLine(
                          label: 'Bonus temps',
                          value: '+${_state.timeBonus}',
                        ),
                        ScoreLine(
                          label: 'Bonus vies',
                          value: '+${_state.livesBonus}',
                        ),
                        ScoreLine(
                          label: 'Score de la partie',
                          value: '${_state.score}',
                        ),
                        ScoreLine(
                          label: 'Pièces gagnées',
                          value: '+${_state.coins}',
                        ),
                        if (_result != null) ...[
                          const Divider(height: 24),
                          ScoreLine(
                            label: 'Ancien score',
                            value: '${_result!.previousScore}',
                          ),
                          ScoreLine(
                            label: 'Score conservé',
                            value: '${_result!.savedScore}',
                          ),
                          if (_result!.isNewRecord)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Nouveau record !',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                        if (_saving)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        if (_saveError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _saveError!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          TextButton(
                            onPressed: _save,
                            child: const Text('Réessayer'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saving ? null : _quit,
                          child: const Text('Continuer'),
                        ),
                      ],
                    ),
                    'lost': (_, _) => GamePanel(
                      title: _game.loseReason,
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
