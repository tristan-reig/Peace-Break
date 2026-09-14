import 'package:flutter/material.dart';

enum PowerType {
  extraLife(
    label: '+1',
    color: Color(0xFFE05263),
    icon: Icons.favorite,
    good: true,
  ),
  widerPaddle(
    label: '↔',
    color: Color(0xFF8BC34A),
    icon: Icons.open_in_full,
    good: true,
  ),
  narrowerPaddle(
    label: '><',
    color: Color(0xFFFF8A65),
    icon: Icons.close_fullscreen,
    good: false,
  ),
  fasterBall(
    label: '»',
    color: Color(0xFFBA68C8),
    icon: Icons.fast_forward,
    good: false,
  );

  const PowerType({
    required this.label,
    required this.color,
    required this.icon,
    required this.good,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool good;
}

const double kPowerDuration = 8;

const double kDropChance = 0.2;
