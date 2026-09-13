import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/play_area.dart';
import 'game_config.dart';

class PeaceBreakGame extends FlameGame with HasCollisionDetection {
  PeaceBreakGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
        ),
      );

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
}
