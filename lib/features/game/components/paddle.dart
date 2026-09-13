import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class Paddle extends RectangleComponent with CollisionCallbacks {
  Paddle()
    : super(
        size: Vector2(kPaddleWidth, kPaddleHeight),
        position: Vector2(kGameWidth / 2, kPaddleY),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFB56BD8),
      );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void moveTo(double x) {
    final half = size.x / 2;
    position.x = x.clamp(half, kGameWidth - half);
  }
}
