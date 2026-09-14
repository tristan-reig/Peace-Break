class StageProgress {
  const StageProgress({required this.stageNumber, required this.bestScore});

  final int stageNumber;
  final int bestScore;

  factory StageProgress.fromMap(Map<String, dynamic> map) => StageProgress(
    stageNumber: map['stage_number'] as int,
    bestScore: map['best_score'] as int,
  );
}
