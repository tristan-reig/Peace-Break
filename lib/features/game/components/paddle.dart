import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../skins.dart';

class Paddle extends RectangleComponent with CollisionCallbacks {
  Paddle({SkinStyle? style})
    : style = style ?? kDefaultPaddleStyle,
      super(
        size: Vector2(kPaddleWidth, kPaddleHeight),
        position: Vector2(kGameWidth / 2, kPaddleY),
        anchor: Anchor.center,
      );

  final SkinStyle style;

  @override
  void render(Canvas canvas) {
    paintPaddle(canvas, size.toRect(), style);
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void moveTo(double x) {
    final half = size.x / 2;
    position.x = x.clamp(half, kGameWidth - half);
  }

  void resizeTo(double width) {
    final center = position.x;
    size = Vector2(width, kPaddleHeight);
    for (final hitbox in children.whereType<RectangleHitbox>()) {
      hitbox.size = Vector2(width, kPaddleHeight);
      hitbox.position = Vector2.zero();
    }
    moveTo(center);
  }
}
