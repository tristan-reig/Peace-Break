import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SkinPattern { flat, grain, neon, ember, crystal }

class SkinStyle {
  const SkinStyle({
    required this.colors,
    this.pattern = SkinPattern.flat,
    this.glow,
    this.stroke,
  });

  final List<Color> colors;
  final SkinPattern pattern;

  final Color? glow;

  final Color? stroke;
}

const kDefaultPaddleStyle = SkinStyle(
  colors: [Color(0xFF7DFFA8), Color(0xFF1F9E4D)],
  pattern: SkinPattern.neon,
  glow: Color(0xFF3DFF7A),
);

const kDefaultBallStyle = SkinStyle(
  colors: [Color(0xFFFFE9B0), Color(0xFFFFB000)],
  glow: Color(0xFFFFB000),
);

const Map<String, SkinStyle> kSkinStyles = {
  'paddle_wood': SkinStyle(
    colors: [Color(0xFFC08E5E), Color(0xFF6D4425)],
    pattern: SkinPattern.grain,
    stroke: Color(0xFF4A2D16),
  ),
  'paddle_neon': SkinStyle(
    colors: [Color(0xFF7FFFF6), Color(0xFF00B8D4)],
    pattern: SkinPattern.neon,
    glow: Color(0xFF00E5FF),
  ),
  'ball_fire': SkinStyle(
    colors: [Color(0xFFFFE082), Color(0xFFFF7043), Color(0xFFD84315)],
    pattern: SkinPattern.ember,
    glow: Color(0xFFFF6E40),
  ),
  'ball_crystal': SkinStyle(
    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA), Color(0xFF26C6DA)],
    pattern: SkinPattern.crystal,
    stroke: Color(0xCCFFFFFF),
  ),
};

SkinStyle paddleStyle(String? id) => kSkinStyles[id] ?? kDefaultPaddleStyle;
SkinStyle ballStyle(String? id) => kSkinStyles[id] ?? kDefaultBallStyle;

void paintPaddle(Canvas canvas, Rect rect, SkinStyle style) {
  final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));

  if (style.glow != null) {
    canvas.drawRRect(
      rrect.inflate(2),
      Paint()
        ..color = style.glow!.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  canvas.drawRRect(
    rrect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: style.colors,
      ).createShader(rect),
  );

  canvas.save();
  canvas.clipRRect(rrect);

  switch (style.pattern) {
    case SkinPattern.grain:
      final grain = Paint()
        ..color = const Color(0x33000000)
        ..strokeWidth = 1.2;
      for (var x = rect.left + 4; x < rect.right; x += 7) {
        canvas.drawLine(
          Offset(x, rect.top),
          Offset(x - 2.5, rect.bottom),
          grain,
        );
      }
    case SkinPattern.neon:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.84,
            height: rect.height * 0.26,
          ),
          Radius.circular(rect.height * 0.13),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    case SkinPattern.flat:
    case SkinPattern.ember:
    case SkinPattern.crystal:
      break;
  }

  canvas.drawRect(
    Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.38),
    Paint()..color = Colors.white.withValues(alpha: 0.16),
  );
  canvas.restore();

  if (style.stroke != null) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = style.stroke!,
    );
  }
}

void paintBall(Canvas canvas, Offset center, double radius, SkinStyle style) {
  if (style.glow != null) {
    canvas.drawCircle(
      center,
      radius * 1.3,
      Paint()
        ..color = style.glow!.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
    );
  }

  final bounds = Rect.fromCircle(center: center, radius: radius);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.95,
        colors: style.colors,
      ).createShader(bounds),
  );

  switch (style.pattern) {
    case SkinPattern.crystal:
      final facet = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, radius * 0.09);
      for (var i = 0; i < 3; i++) {
        final angle = i * math.pi / 3;
        final dir = Offset(math.cos(angle), math.sin(angle)) * radius * 0.85;
        canvas.drawLine(center + dir, center - dir, facet);
      }
    case SkinPattern.ember:
      canvas.drawCircle(
        center,
        radius * 0.45,
        Paint()
          ..color = const Color(0xFFFFF3B0).withValues(alpha: 0.75)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.35),
      );
    case SkinPattern.flat:
    case SkinPattern.grain:
    case SkinPattern.neon:
      break;
  }

  canvas.drawCircle(
    center.translate(-radius * 0.32, -radius * 0.36),
    radius * 0.26,
    Paint()..color = Colors.white.withValues(alpha: 0.6),
  );

  if (style.stroke != null) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = style.stroke!,
    );
  }
}
