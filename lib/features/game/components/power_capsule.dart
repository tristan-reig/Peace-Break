import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';
import '../peace_break_game.dart';
import '../power_up.dart';
import 'paddle.dart';

class PowerCapsule extends PositionComponent
    with CollisionCallbacks, HasGameReference<PeaceBreakGame> {
  PowerCapsule({required Vector2 position, required this.type})
    : super(position: position, size: Vector2(26, 26), anchor: Anchor.center);

  final PowerType type;
  static const double _fallSpeed = 130;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _fallSpeed * dt;
    if (position.y > kGameHeight + size.y) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = type.color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white70,
    );

    // Le libellé indique la nature de l'effet sans dépendre de la couleur,
    // ce qui reste lisible en cas de daltonisme.
    final painter = TextPainter(
      text: TextSpan(
        text: type.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset((size.x - painter.width) / 2, (size.y - painter.height) / 2),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Paddle) {
      game.applyPower(type);
      removeFromParent();
    }
  }
}
