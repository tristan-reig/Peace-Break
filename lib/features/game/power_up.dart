import 'package:flutter/material.dart';

enum PowerType {
  extraLife(
    glyph: PowerGlyph.heart,
    color: Color(0xFF3DFF7A),
    icon: Icons.favorite,
    good: true,
  ),
  widerPaddle(
    glyph: PowerGlyph.expand,
    color: Color(0xFF3DE8FF),
    icon: Icons.open_in_full,
    good: true,
  ),
  narrowerPaddle(
    glyph: PowerGlyph.shrink,
    color: Color(0xFFFF3D7F),
    icon: Icons.close_fullscreen,
    good: false,
  ),
  fasterBall(
    glyph: PowerGlyph.bolt,
    color: Color(0xFFFFB000),
    icon: Icons.fast_forward,
    good: false,
  );

  const PowerType({
    required this.glyph,
    required this.color,
    required this.icon,
    required this.good,
  });

  final PowerGlyph glyph;
  final Color color;
  final IconData icon;
  final bool good;
}

enum PowerGlyph { heart, expand, shrink, bolt }

const double kPowerDuration = 8;
const double kDropChance = 0.22;
