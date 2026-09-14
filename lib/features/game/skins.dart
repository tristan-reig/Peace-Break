import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _t0 = 0.6;

enum SkinPattern {
  flat,
  grain,
  neon,
  ember,
  crystal,
  plasma,
  circuit,
  vector,
  pixel,
  voidCore,
}

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
  // --- Raquettes ---
  'paddle_wood': SkinStyle(
    colors: [Color(0xFFC08E5E), Color(0xFF6D4425)],
    pattern: SkinPattern.grain,
    stroke: Color(0xFF4A2D16),
  ),
  'paddle_neon': SkinStyle(
    colors: [Color(0xFF7FFFF6), Color(0xFF00B8D4)],
    pattern: SkinPattern.neon,
    glow: Color(0xFF3DE8FF),
  ),
  'paddle_plasma': SkinStyle(
    colors: [Color(0xFFFFB0F5), Color(0xFF9B30FF)],
    pattern: SkinPattern.plasma,
    glow: Color(0xFFD65BFF),
  ),
  'paddle_circuit': SkinStyle(
    colors: [Color(0xFF1B3A2A), Color(0xFF0D1F16)],
    pattern: SkinPattern.circuit,
    stroke: Color(0xFF3DFF7A),
    glow: Color(0xFF3DFF7A),
  ),
  'paddle_vector': SkinStyle(
    colors: [Color(0x223DE8FF), Color(0x113DE8FF)],
    pattern: SkinPattern.vector,
    stroke: Color(0xFF3DE8FF),
    glow: Color(0xFF3DE8FF),
  ),

  // --- Balles ---
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
  'ball_pixel': SkinStyle(
    colors: [Color(0xFF7DFFA8), Color(0xFF1F9E4D)],
    pattern: SkinPattern.pixel,
  ),
  'ball_plasma': SkinStyle(
    colors: [Color(0xFFFFE0FF), Color(0xFFD65BFF), Color(0xFF6A0DAD)],
    pattern: SkinPattern.plasma,
    glow: Color(0xFFD65BFF),
  ),
  'ball_void': SkinStyle(
    colors: [Color(0xFF1A1A22), Color(0xFF000000)],
    pattern: SkinPattern.voidCore,
    stroke: Color(0xFF9B30FF),
    glow: Color(0xFF6A0DAD),
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

    case SkinPattern.plasma:
      final wave = Path();
      for (var x = 0.0; x <= rect.width; x += 2) {
        final y =
            rect.center.dy +
            math.sin(x / rect.width * math.pi * 4 + _t0) * rect.height * 0.22;
        if (x == 0) {
          wave.moveTo(rect.left + x, y);
        } else {
          wave.lineTo(rect.left + x, y);
        }
      }
      canvas.drawPath(
        wave,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.9),
      );

    case SkinPattern.circuit:
      final trace = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF3DFF7A).withValues(alpha: 0.85);
      canvas.drawLine(
        Offset(rect.left + 4, rect.center.dy),
        Offset(rect.right - 4, rect.center.dy),
        trace,
      );
      for (var x = rect.left + 6; x < rect.right - 4; x += 11) {
        canvas.drawLine(
          Offset(x, rect.center.dy - rect.height * 0.22),
          Offset(x, rect.center.dy + rect.height * 0.22),
          trace,
        );
        canvas.drawCircle(
          Offset(x, rect.center.dy),
          1.8,
          Paint()..color = const Color(0xFF3DFF7A),
        );
      }

    case SkinPattern.vector:
    case SkinPattern.flat:
    case SkinPattern.ember:
    case SkinPattern.crystal:
    case SkinPattern.pixel:
    case SkinPattern.voidCore:
      break;
  }

  if (style.pattern != SkinPattern.vector) {
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.38),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }
  canvas.restore();

  if (style.stroke != null) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.pattern == SkinPattern.vector ? 2 : 1.2
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

    case SkinPattern.plasma:
      for (var i = 0; i < 3; i++) {
        final angle = _t0 + i * 2 * math.pi / 3;
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.42,
          radius * 0.3,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.3),
        );
      }

    case SkinPattern.pixel:
      final cell = radius * 2 / 5;
      canvas.save();
      canvas.clipPath(Path()..addOval(bounds));
      for (var row = 0; row < 5; row++) {
        for (var col = 0; col < 5; col++) {
          if ((row + col) % 2 != 0) continue;
          canvas.drawRect(
            Rect.fromLTWH(
              bounds.left + col * cell,
              bounds.top + row * cell,
              cell,
              cell,
            ),
            Paint()..color = Colors.white.withValues(alpha: 0.18),
          );
        }
      }
      canvas.restore();

    case SkinPattern.voidCore:
      canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.black);
      canvas.drawCircle(
        center,
        radius * 0.78,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF9B30FF).withValues(alpha: 0.7),
      );

    case SkinPattern.flat:
    case SkinPattern.grain:
    case SkinPattern.neon:
    case SkinPattern.circuit:
    case SkinPattern.vector:
      break;
  }

  if (style.pattern != SkinPattern.voidCore) {
    canvas.drawCircle(
      center.translate(-radius * 0.32, -radius * 0.36),
      radius * 0.26,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

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
