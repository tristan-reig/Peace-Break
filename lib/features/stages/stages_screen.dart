import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/stage_progress.dart';
import '../../services/profile_controller.dart';
import '../../services/stage_service.dart';
import '../game/levels.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});
  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  late Future<List<StageProgress>> _future;

  @override
  void initState() {
    super.initState();
    _future = StageService().completedStages();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileController>().load(),
    );
  }

  void _reload() {
    setState(() {
      _future = StageService().completedStages();
    });
  }

  Future<void> _play(int stage) async {
    final maxLives = context.read<ProfileController>().profile?.maxLives ?? 3;
    await Navigator.pushNamed(
      context,
      Routes.game,
      arguments: {'stage': stage, 'maxLives': maxLives},
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final nextStage =
        context.watch<ProfileController>().profile?.nextStage ?? 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Stages')),
      body: FutureBuilder<List<StageProgress>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chargement impossible'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final scores = {
            for (final p in snapshot.data ?? const <StageProgress>[])
              p.stageNumber: p.bestScore,
          };

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: kLevelCount,
            itemBuilder: (context, index) {
              final stage = index + 1;
              return _StageTile(
                stage: stage,
                bestScore: scores[stage],
                locked: stage > nextStage,
                isNext: stage == nextStage,
                onTap: () => _play(stage),
              );
            },
          );
        },
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({
    required this.stage,
    required this.bestScore,
    required this.locked,
    required this.isNext,
    required this.onTap,
  });

  final int stage;
  final int? bestScore;
  final bool locked;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = locked
        ? AppTheme.greenDim
        : isNext
        ? AppTheme.green
        : AppTheme.accent;

    final tile = Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (locked)
            const Icon(Icons.lock, size: 30, color: AppTheme.textDim)
          else
            Text(
              '$stage',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          const SizedBox(height: 4),
          if (locked)
            Text(
              'Stage $stage',
              style: const TextStyle(fontSize: 11, color: AppTheme.textDim),
            )
          else if (bestScore != null) ...[
            const Text('Score', style: TextStyle(fontSize: 11)),
            Text(
              '$bestScore',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ] else
            const Text(
              'Nouveau',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.green,
              ),
            ),
        ],
      ),
    );

    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Material(
        color: locked ? AppTheme.bg : AppTheme.panel,
        child: locked ? tile : InkWell(onTap: onTap, child: tile),
      ),
    );
  }
}
