import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../peace_break_game.dart';
import 'paddle.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<PeaceBreakGame> {
  Ball({required Vector2 position})
    : super(
        radius: kBallRadius,
        position: position,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF4FC3F7),
      );

  Vector2 velocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  void launch() {
    final angle = (Random().nextDouble() - 0.5) * 0.6;
    velocity = Vector2(sin(angle), -cos(angle))..scaleTo(kBallSpeed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.x - radius < 0) {
      position.x = radius;
      velocity.x = velocity.x.abs();
    } else if (position.x + radius > kGameWidth) {
      position.x = kGameWidth - radius;
      velocity.x = -velocity.x.abs();
    }
    if (position.y - radius < 0) {
      position.y = radius;
      velocity.y = velocity.y.abs();
    }

    if (position.y - radius > kGameHeight) {
      game.onBallLost();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Paddle) _bounceOnPaddle(other);
  }

  void _bounceOnPaddle(Paddle paddle) {
    final offset = (position.x - paddle.position.x) / (paddle.size.x / 2);
    final angle = offset.clamp(-1.0, 1.0) * kMaxBounceAngle;
    velocity = Vector2(sin(angle), -cos(angle))..scaleTo(velocity.length);

    position.y = paddle.position.y - paddle.size.y / 2 - radius - 0.5;
  }
}
