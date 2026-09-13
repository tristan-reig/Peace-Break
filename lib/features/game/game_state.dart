import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  GameState({required this.stage, required this.maxLives}) : lives = maxLives;

  final int stage;
  final int maxLives;

  int lives;
  int score = 0;
  int coins = 0;

  static const _scorePerHp = {1: 50, 2: 120, 3: 200};
  static const _coinsPerHp = {1: 5, 2: 12, 3: 20};

  void rewardBrick(int initialHp) {
    score += _scorePerHp[initialHp] ?? 50;
    coins += _coinsPerHp[initialHp] ?? 5;
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
