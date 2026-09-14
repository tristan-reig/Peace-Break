import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/stage_progress.dart';

class StageResult {
  const StageResult({
    required this.previousScore,
    required this.savedScore,
    required this.coinsAdded,
  });

  final int previousScore;
  final int savedScore;
  final int coinsAdded;

  bool get isNewRecord => savedScore > previousScore;
}

class StageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<StageResult> complete({
    required int stage,
    required int score,
    required int coins,
  }) async {
    final rows = await _client.rpc(
      'complete_stage',
      params: {'p_stage': stage, 'p_score': score, 'p_coins': coins},
    ) as List<dynamic>;

    final row = rows.first as Map<String, dynamic>;
    return StageResult(
      previousScore: row['previous_score'] as int,
      savedScore: row['saved_score'] as int,
      coinsAdded: row['coins_added'] as int,
    );
  }

  Future<List<StageProgress>> completedStages() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Aucun utilisateur connecté');

    final rows = await _client
        .from('stage_progress')
        .select('stage_number, best_score')
        .eq('user_id', userId)
        .order('stage_number');

    return rows
        .map((row) => StageProgress.fromMap(row))
        .toList(growable: false);
  }
}
