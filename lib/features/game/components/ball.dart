import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../peace_break_game.dart';
import 'paddle.dart';
import 'brick.dart';

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
  bool _bouncedThisFrame = false;

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
    _bouncedThisFrame = false;
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
    if (other is Brick) _bounceOnBrick(other);
  }

  void _bounceOnPaddle(Paddle paddle) {
    final offset = (position.x - paddle.position.x) / (paddle.size.x / 2);
    final angle = offset.clamp(-1.0, 1.0) * kMaxBounceAngle;
    velocity = Vector2(sin(angle), -cos(angle))..scaleTo(velocity.length);

    position.y = paddle.position.y - paddle.size.y / 2 - radius - 0.5;
  }

  void _bounceOnBrick(Brick brick) {
    final rect = brick.toAbsoluteRect();
    final dx = position.x - rect.center.dx;
    final dy = position.y - rect.center.dy;
    final overlapX = (rect.width / 2 + radius) - dx.abs();
    final overlapY = (rect.height / 2 + radius) - dy.abs();

    if (!_bouncedThisFrame) {
      _bouncedThisFrame = true;
      if (overlapX < overlapY) {
        velocity.x = dx > 0 ? velocity.x.abs() : -velocity.x.abs();
        position.x += dx > 0 ? overlapX : -overlapX;
      } else {
        velocity.y = dy > 0 ? velocity.y.abs() : -velocity.y.abs();
        position.y += dy > 0 ? overlapY : -overlapY;
      }
    }

    brick.hit();
  }

  void setSpeed(double speed) {
    if (velocity.isZero()) return;
    velocity.scaleTo(speed);
  }
}
