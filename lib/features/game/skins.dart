import 'package:flutter/material.dart';

const Map<String, Color> kSkinColors = {
  'paddle_wood': Color(0xFF8D6E63),
  'paddle_neon': Color(0xFF00E5FF),
  'ball_fire': Color(0xFFFF7043),
  'ball_crystal': Color(0xFFB2EBF2),
};

const Color kDefaultPaddleColor = Color(0xFFB56BD8);
const Color kDefaultBallColor = Color(0xFF4FC3F7);

Color paddleColor(String? skinId) => kSkinColors[skinId] ?? kDefaultPaddleColor;

Color ballColor(String? skinId) => kSkinColors[skinId] ?? kDefaultBallColor;
