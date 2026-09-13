class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.totalScore,
    required this.coins,
    required this.maxLives,
    required this.nextStage,
  });

  final String id;
  final String username;
  final int totalScore;
  final int coins;
  final int maxLives;
  final int nextStage;

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as String,
    username: map['username'] as String,
    totalScore: map['total_score'] as int,
    coins: map['coins'] as int,
    maxLives: map['max_lives'] as int,
    nextStage: map['next_stage'] as int,
  );
}
