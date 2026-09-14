import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../game_config.dart';
import '../peace_break_game.dart';
import '../power_up.dart';
import 'paddle.dart';

class PowerCapsule extends PositionComponent
    with CollisionCallbacks, HasGameReference<PeaceBreakGame> {
  PowerCapsule({required Vector2 position, required this.type})
    : super(position: position, size: Vector2(30, 30), anchor: Anchor.center);

  final PowerType type;
  static const double _fallSpeed = 130;

  double _t = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    position.y += _fallSpeed * dt;
    if (position.y > kGameHeight + size.y) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2 - 2;
    final pulse = 0.65 + 0.35 * math.sin(_t * 5);
    final path = _hexagon(center, radius);

    canvas.drawPath(
      path,
      Paint()
        ..color = type.color.withValues(alpha: 0.4 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    canvas.drawPath(
      path,
      Paint()..color = AppTheme.gameBg.withValues(alpha: 0.85),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = type.good ? 2.5 : 1.5
        ..color = type.color,
    );

    _drawGlyph(canvas, center, radius * 0.52);
  }

  Path _hexagon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 6 + i * math.pi / 3;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  void _drawGlyph(Canvas canvas, Offset c, double r) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = type.color;
    final fill = Paint()..color = type.color;

    switch (type.glyph) {
      case PowerGlyph.heart:
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 1.6, height: r * 0.55),
          fill,
        );
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 0.55, height: r * 1.6),
          fill,
        );

      case PowerGlyph.expand:
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 0.3, height: r * 1.2),
          fill,
        );
        for (final dir in [-1.0, 1.0]) {
          final tip = c + Offset(dir * r, 0);
          canvas.drawPath(
            Path()
              ..moveTo(tip.dx - dir * r * 0.5, tip.dy - r * 0.5)
              ..lineTo(tip.dx, tip.dy)
              ..lineTo(tip.dx - dir * r * 0.5, tip.dy + r * 0.5),
            stroke,
          );
        }

      case PowerGlyph.shrink:
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 0.3, height: r * 1.2),
          fill,
        );
        for (final dir in [-1.0, 1.0]) {
          final tip = c + Offset(dir * r * 0.45, 0);
          canvas.drawPath(
            Path()
              ..moveTo(tip.dx + dir * r * 0.5, tip.dy - r * 0.5)
              ..lineTo(tip.dx, tip.dy)
              ..lineTo(tip.dx + dir * r * 0.5, tip.dy + r * 0.5),
            stroke,
          );
        }

      case PowerGlyph.bolt:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + r * 0.35, c.dy - r)
            ..lineTo(c.dx - r * 0.45, c.dy + r * 0.15)
            ..lineTo(c.dx + r * 0.05, c.dy + r * 0.15)
            ..lineTo(c.dx - r * 0.35, c.dy + r)
            ..lineTo(c.dx + r * 0.45, c.dy - r * 0.15)
            ..lineTo(c.dx - r * 0.05, c.dy - r * 0.15)
            ..close(),
          fill,
        );
    }
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
