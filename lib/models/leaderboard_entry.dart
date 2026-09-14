class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.totalScore,
  });

  final int rank;
  final String userId;
  final String username;
  final int totalScore;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) =>
      LeaderboardEntry(
        rank: (map['rank'] as num).toInt(),
        userId: map['id'] as String,
        username: map['username'] as String,
        totalScore: map['total_score'] as int,
      );
}
