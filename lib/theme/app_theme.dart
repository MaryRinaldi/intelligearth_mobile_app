import 'package:flutter/material.dart';

class AppTheme {
  // Colori principali
  static const primaryColor = Color(0xFF305A72); // Blu navy
  static const accentColor = Color(0xFFBF20EC); // Viola acceso
  static const darkColor = Color(0xFF272F40); // Blu scuro
  static const lightColor = Color(0xFFFDFDFD); // Bianco
  static const neutralColor = Color(0xFF425950); // Verde grigio

  // Gradienti
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      Color(0xFF3A6D89), // Versione più chiara del primaryColor
    ],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor,
      Color(0xFFD042FF), // Versione più chiara dell'accentColor
    ],
  );

  // Elevazioni e ombre
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color.fromRGBO(39, 47, 64, 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // Bordi arrotondati
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  // Spaziature
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Animazioni
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: lightColor,
        onSurface: darkColor,
        onPrimary: lightColor,
        onSecondary: lightColor,
      ),
      // Stile dei testi
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkColor,
        ),
      ),
      // Stile dei bottoni
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          backgroundColor: primaryColor,
          foregroundColor: lightColor,
        ),
      ),
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        color: lightColor,
      ),
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: lightColor,
        foregroundColor: darkColor,
        centerTitle: true,
      ),
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: const Color.fromRGBO(48, 90, 114, 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.all(spacingMedium),
      ),
    );
  }
}
