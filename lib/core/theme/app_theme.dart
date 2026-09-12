import 'package:flutter/material.dart';

class AppTheme {
  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0F2027), // Deep Dark Blue
    Color(0xFF203A43), // Medium Blue
    Color(0xFF2C5364), // Teal
  ];

  static const List<Color> colorfulGradient = [
    Color(0xFF1E3C72), // Deep Royal Blue
    Color(0xFF6A11CB), // Rich Purple
    Color(0xFF2575FC), // Vibrant Cyan/Blue
  ];

  static const List<Color> liveGradient = [
    Color(0xFF11998e), // Emerald Green
    Color(0xFF38ef7d), // Lime Green
  ];

  static const List<Color> offlineGradient = [
    Color(0xFFcb2d3e), // Dark Red
    Color(0xFFef473a), // Bright Red
  ];

  // Accent Colors
  static const Color liveColor = Color(0xFF2ECC71); // Green
  static const Color atStopColor = Color(0xFF3498DB); // Blue
  static const Color delayedColor = Color(0xFFE67E22); // Orange
  static const Color offlineColor = Color(0xFFE74C3C); // Red
  static const Color secondaryColor = Color(0xFF6A11CB); // Secondary accent color
  static const Color primaryColor = Color(0xFF1E3C72); // Primary accent color
  static const Color notStartedColor = Color(0xFF95A5A6); // Grey
  static const Color favoriteColor = Color(0xFF9B59B6); // Amethyst Purple
  static const Color successColor = Color(0xFF2ECC71);

  // Border Radius
  static const double cardRadius = 18.0;
  static const double buttonRadius = 12.0;

  // Box Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        )
      ];

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1E3C72),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E3C72),
        secondary: Color(0xFF6A11CB),
        surface: Colors.white,
        background: Color(0xFFF7F9FC),
        error: Color(0xFFE74C3C),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
        bodyLarge: TextStyle(color: Color(0xFF5A6B7C)),
        bodyMedium: TextStyle(color: Color(0xFF7F8C8D)),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF6A11CB),
      scaffoldBackgroundColor: const Color(0xFF0F111E),
      cardTheme: const CardThemeData(
        color: Color(0xFF1B1D2A),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6A11CB),
        secondary: Color(0xFF2575FC),
        surface: Color(0xFF1B1D2A),
        background: Color(0xFF0F111E),
        error: Color(0xFFE74C3C),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(color: Color(0xFFB2BEC3)),
        bodyMedium: TextStyle(color: Color(0xFF636E72)),
      ),
    );
  }
}
