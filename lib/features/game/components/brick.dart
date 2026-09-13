import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../peace_break_game.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<PeaceBreakGame> {
  Brick({required Vector2 position, required this.hitPoints})
    : super(
        size: Vector2(kBrickWidth, kBrickHeight),
        position: position,
        anchor: Anchor.topLeft,
      );

  int hitPoints;

  static const _colors = <int, Color>{
    1: Color(0xFF8BC34A),
    2: Color(0xFFFFB74D),
    3: Color(0xFFE05263),
  };

  @override
  Future<void> onLoad() async {
    _refreshColor();
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  void _refreshColor() {
    paint = Paint()..color = _colors[hitPoints] ?? _colors[1]!;
  }

  bool hit() {
    hitPoints--;
    if (hitPoints > 0) {
      _refreshColor();
      return false;
    }
    removeFromParent();
    game.onBrickDestroyed(this);
    return true;
  }
}
