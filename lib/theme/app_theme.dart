import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF668FE6); // Blu chiaro
  static const Color secondaryColor = Color(0xFF39437A); // Blu scuro
  static const Color accentColor = Color(0xFFBF20EC); // Viola
  static const Color successColor = Color(0xFF4CAF50); // Verde
  static const Color warningColor = Color(0xFFFFC107); // Giallo
  static const Color errorColor = Color(0xFFE53935); // Rosso
  static const Color darkColor = Color(0xFF1E1E1E); // Nero
  static const Color neutralColor = Color(0xFF425950); // Grigio scuro
  static const Color lightColor = Color(0xFFFAFAFA); // Bianco sporco
  static const Color textOnPrimaryColor =
      Colors.white; // Testo su sfondo primario
  static const Color textOnLightColor =
      Color(0xFF39437A); // Testo su sfondo chiaro

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF668FE6), // primaryColor
      Color(0xFF39437A), // secondaryColor
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBF20EC), // accentColor
      Color(0xFF9918B9), // darker version of accentColor
    ],
  );

  // Neumorphic shadows
  static List<BoxShadow> get neumorphicShadow => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 204),
          offset: const Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Color.fromRGBO(48, 90, 114, 0.2),
          offset: const Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];

  // Soft shadows for cards and elevated elements
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

  // Bordi arrotondati moderni
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXLarge = 32.0;

  // Spaziature generose
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Animazioni fluide
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        onSurface: darkColor,
        onPrimary: textOnPrimaryColor,
        onSecondary: textOnPrimaryColor,
        error: errorColor,
      ),
      // Typography moderna con Google Fonts
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textOnLightColor,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textOnLightColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textOnLightColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          letterSpacing: 0.15,
          color: textOnLightColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          letterSpacing: 0.25,
          color: textOnLightColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
          color: textOnLightColor,
        ),
      ),
      // Bottoni moderni
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
          foregroundColor: Colors.white,
          minimumSize: Size(0, 48), // Dimensione minima per accessibilità
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) return 0;
              return 2;
            },
          ),
        ),
      ),
      // Card Theme moderno
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        color: Colors.white,
        margin: EdgeInsets.all(spacingSmall),
      ),
      // AppBar Theme moderno
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkColor, size: 24),
        titleTextStyle: GoogleFonts.inter(
          color: darkColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      // Input Decoration moderna
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacingMedium),
        hintStyle: GoogleFonts.inter(
          color: neutralColor.withValues(alpha: 128),
          fontSize: 16,
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        extendedPadding: EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkColor,
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: errorColor,
      ),
    );
  }
}

// CustomAppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textOnPrimaryColor,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: automaticallyImplyLeading,
        iconTheme: IconThemeData(color: AppTheme.textOnPrimaryColor),
        actions: actions,
        flexibleSpace: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textOnPrimaryColor.withValues(alpha: 26),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textOnPrimaryColor.withValues(alpha: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130);
}

// ExampleScreen
class ExampleScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const ExampleScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: actions,
      ),
      body: body,
    );
  }
}
