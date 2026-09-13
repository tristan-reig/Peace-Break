import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/ball.dart';
import 'components/brick.dart';
import 'components/paddle.dart';
import 'components/play_area.dart';
import 'game_config.dart';
import 'game_state.dart';
import 'levels.dart';

class PeaceBreakGame extends FlameGame with HasCollisionDetection {
  PeaceBreakGame({required this.state})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
        ),
      );

  final GameState state;
  int get stage => state.stage;

  late final Paddle paddle;
  late final Ball ball;

  int _remainingBricks = 0;
  bool _over = false;

  String loseReason = '';
  VoidCallback? onWin;

  @override
  Color backgroundColor() => const Color(0xFF101018);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    paddle = Paddle();
    ball = Ball(position: Vector2(kGameWidth / 2, kPaddleY - 40));

    world.addAll([PlayArea(), paddle, ball]);

    _buildWall();
    state.startTimer(level(stage).seconds.toDouble());
    ball.launch();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_over) return;
    if (state.tick(dt)) _lose('Temps écoulé');
  }

  void _buildWall() {
    final def = level(stage);
    var count = 0;

    for (var row = 0; row < def.rows.length; row++) {
      final line = def.rows[row];
      for (var col = 0; col < kGridColumns && col < line.length; col++) {
        final hp = int.tryParse(line[col]);
        if (hp == null || hp <= 0) continue;

        world.add(
          Brick(
            position: Vector2(
              kGridMargin + col * (kBrickWidth + kBrickGap),
              kGridTop + row * (kBrickHeight + kBrickGap),
            ),
            hitPoints: hp,
          ),
        );
        count++;
      }
    }
    _remainingBricks = count;
  }

  void movePaddle(double x) {
    paddle.moveTo(x);
    if (ball.velocity.isZero()) ball.position.x = paddle.position.x;
  }

  void onBrickDestroyed(Brick brick) {
    state.rewardBrick(brick.initialHitPoints);
    _remainingBricks--;
    if (_remainingBricks <= 0) _win();
  }

  void onBallLost() {
    if (_over) return;

    if (state.loseLife()) {
      _lose('Plus de vies');
      return;
    }
    _resetBall();
  }

  void _resetBall() {
    ball
      ..position = Vector2(paddle.position.x, kPaddleY - 40)
      ..velocity = Vector2.zero();
    ball.launch();
  }

  void _win() {
    if (_over) return;
    _over = true;
    state.applyVictoryBonuses();
    ball.velocity = Vector2.zero();
    pauseEngine();
    onWin?.call();
    overlays.add('won');
  }

  void _lose(String reason) {
    if (_over) return;
    _over = true;
    loseReason = reason;
    ball.velocity = Vector2.zero();
    pauseEngine();
    overlays.add('lost');
  }

  void togglePause() {
    if (_over) return;
    if (paused) {
      overlays.remove('paused');
      resumeEngine();
    } else {
      pauseEngine();
      overlays.add('paused');
    }
  }
}
