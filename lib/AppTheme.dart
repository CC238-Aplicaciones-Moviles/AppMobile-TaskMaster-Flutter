import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFA62424),
      onPrimary: Colors.white,
      secondary: Color(0xFFF3D0D4),
      onSecondary: Colors.black,
      error: Color(0xFFB00020),
      onError: Colors.white,
      background: Color(0xFFFDFDFD),
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );
}
