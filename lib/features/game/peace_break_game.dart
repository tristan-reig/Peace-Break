import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/play_area.dart';
import 'components/brick.dart';
import 'game_config.dart';
import 'levels.dart';

class PeaceBreakGame extends FlameGame with HasCollisionDetection {
  PeaceBreakGame({this.stage = 1})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
        ),
      );

  final int stage;
  int _remainingBricks = 0;

  late final Paddle paddle;
  late final Ball ball;

  @override
  Color backgroundColor() => const Color(0xFF101018);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    paddle = Paddle();
    ball = Ball(position: Vector2(kGameWidth / 2, kPaddleY - 40));

    world.addAll([PlayArea(), paddle, ball]);
    ball.launch();
    _buildWall();
  }

  void movePaddle(double x) {
    paddle.moveTo(x);
    if (ball.velocity.isZero()) ball.position.x = paddle.position.x;
  }

  void onBallLost() {
    ball
      ..position = Vector2(paddle.position.x, kPaddleY - 40)
      ..velocity = Vector2.zero();
    ball.launch();
  }

  void _buildWall() {
    final rows = levelRows(stage);
    var count = 0;

    for (var row = 0; row < rows.length; row++) {
      final line = rows[row];
      for (var col = 0; col < kGridColumns && col < line.length; col++) {
        final char = line[col];
        final hp = int.tryParse(char);
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

  void onBrickDestroyed(Brick brick) {
    _remainingBricks--;
    if (_remainingBricks <= 0) onStageCleared();
  }

  void onStageCleared() {
    pauseEngine();
    overlays.add('cleared');
  }
}
