import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/inventory_service.dart';
import '../../services/profile_controller.dart';
import '../../services/stage_service.dart';
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

  PeaceBreakGame? _game;

  StageResult? _result;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    var skins = const EquippedSkins();
    try {
      skins = await InventoryService().equipped();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _game = PeaceBreakGame(state: _state, skins: skins)..onWin = _save;
    });
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
    final game = _game;

    if (game == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) game.togglePause();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              InfoBar(
                state: _state,
                onPause: game.togglePause,
                activePowers: () => game.activePowers,
              ),
              Expanded(
                child: GameWidget(
                  game: game,
                  overlayBuilderMap: {
                    'paused': (_, _) => GamePanel(
                      title: 'Pause',
                      children: [
                        ElevatedButton(
                          onPressed: game.togglePause,
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
                          label: 'Score de la partie',
                          value: '${_state.score}',
                        ),
                        ScoreLine(
                          label: 'Bonus temps',
                          value: '+${_state.timeBonus}',
                        ),
                        ScoreLine(
                          label: 'Bonus vies',
                          value: '+${_state.livesBonus}',
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
                                  color: AppTheme.amber,
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
                            style: const TextStyle(color: AppTheme.magenta),
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
                      title: game.loseReason,
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
