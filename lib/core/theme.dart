import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF0A0E0A);
  static const panel = Color(0xFF121A14);
  static const green = Color(0xFF3DFF7A);
  static const greenDim = Color(0xFF1F7A3C);
  static const amber = Color(0xFFFFB000);
  static const magenta = Color(0xFFFF3D7F);
  static const cyan = Color(0xFF3DE8FF);
  static const text = Color(0xFFCFF5DA);
  static const textDim = Color(0xFF6E9C7C);
  static const gameBg = Color(0xFF060A06);

  static const accent = green;

  static const titleFont = 'PressStart2P';
  static const bodyFont = 'PlexMono';

  static TextStyle title(double size, {Color color = green}) => TextStyle(
    fontFamily: titleFont,
    fontSize: size,
    color: color,
    height: 1.5,
    letterSpacing: 1,
    shadows: [
      Shadow(color: color.withValues(alpha: 0.85), blurRadius: 12),
      Shadow(color: color.withValues(alpha: 0.35), blurRadius: 24),
    ],
  );

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: green,
      secondary: amber,
      surface: panel,
      error: magenta,
      onPrimary: bg,
      onSecondary: bg,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      canvasColor: bg,
      dividerTheme: const DividerThemeData(color: greenDim, thickness: 1),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: text, fontSize: 15),
        bodySmall: TextStyle(color: textDim, fontSize: 13),
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: green),
        titleTextStyle: title(13),
        shape: const Border(bottom: BorderSide(color: greenDim, width: 2)),
      ),

      cardTheme: const CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: greenDim, width: 2),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: green, width: 2),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: panel,
        contentTextStyle: TextStyle(color: text, fontFamily: bodyFont),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: green, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.45),
        labelStyle: const TextStyle(color: textDim),
        floatingLabelStyle: const TextStyle(color: green),
        errorStyle: const TextStyle(color: magenta, fontSize: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: greenDim, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: greenDim, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: green, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: magenta, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: magenta, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: bg,
          disabledBackgroundColor: greenDim,
          disabledForegroundColor: textDim,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontFamily: titleFont,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: bg,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: green,
          side: const BorderSide(color: green, width: 2),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: amber),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: green,
        linearTrackColor: greenDim,
      ),

      listTileTheme: const ListTileThemeData(iconColor: green, textColor: text),
    );
  }
}
