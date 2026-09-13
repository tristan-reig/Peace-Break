import 'package:flutter/foundation.dart';

import 'game_config.dart';

class GameState extends ChangeNotifier {
  GameState({required this.stage, required this.maxLives}) : lives = maxLives;

  final int stage;
  final int maxLives;

  int lives;
  int score = 0;
  int coins = 0;

  double timeLeft = 0;
  int timeBonus = 0;
  int livesBonus = 0;

  int get secondsLeft => timeLeft.ceil().clamp(0, 9999);

  static const _scorePerHp = {1: 50, 2: 120, 3: 200};
  static const _coinsPerHp = {1: 5, 2: 12, 3: 20};

  void startTimer(double seconds) {
    timeLeft = seconds;
    notifyListeners();
  }

  bool tick(double dt) {
    if (timeLeft <= 0) return false;
    final before = secondsLeft;
    timeLeft -= dt;
    if (timeLeft <= 0) {
      timeLeft = 0;
      notifyListeners();
      return true;
    }
    if (secondsLeft != before) notifyListeners();
    return false;
  }

  void rewardBrick(int initialHp) {
    score += _scorePerHp[initialHp] ?? 50;
    coins += _coinsPerHp[initialHp] ?? 5;
    notifyListeners();
  }

  void applyVictoryBonuses() {
    timeBonus = secondsLeft * kPointsPerSecondLeft;
    livesBonus = lives * kPointsPerLifeLeft;
    score += timeBonus + livesBonus;
    notifyListeners();
  }

  bool loseLife() {
    lives--;
    notifyListeners();
    return lives <= 0;
  }

  void gainLife() {
    lives++;
    notifyListeners();
  }
}
