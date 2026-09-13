import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF1A1A1F);
  static const accent = Color(0xFFF5A623);
  static const danger = Color(0xFFE05263);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(220, 52),
        backgroundColor: accent,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
