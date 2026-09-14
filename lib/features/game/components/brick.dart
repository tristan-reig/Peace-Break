import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../peace_break_game.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<PeaceBreakGame> {
  Brick({required Vector2 position, required this.hitPoints})
    : initialHitPoints = hitPoints,
      super(
        size: Vector2(kBrickWidth, kBrickHeight),
        position: position,
        anchor: Anchor.topLeft,
      );

  final int initialHitPoints;
  int hitPoints;

  static const _colors = <int, Color>{
    1: Color(0xFF3DFF7A),
    2: Color(0xFFFFB000),
    3: Color(0xFFFF3D7F),
  };

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect().deflate(1);
    final color = _colors[hitPoints] ?? _colors[1]!;

    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.22));

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );

    if (hitPoints > 1) {
      final mark = Paint()
        ..color = color.withValues(alpha: 0.75)
        ..strokeWidth = 2;
      final step = rect.width / hitPoints;
      for (var i = 1; i < hitPoints; i++) {
        final x = rect.left + step * i;
        canvas.drawLine(
          Offset(x, rect.top + 4),
          Offset(x, rect.bottom - 4),
          mark,
        );
      }
    }
  }

  bool hit() {
    hitPoints--;
    if (hitPoints > 0) return false;

    removeFromParent();
    game.onBrickDestroyed(this);
    return true;
  }
}
