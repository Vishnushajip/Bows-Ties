import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF9B6A57);
  static const Color footercolor = Color(0xFFE8D8C3);
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color accentColor = Color(0xFFF5EFE6); // Light unique beige
  static const Color textColor = Color(0xFF333333); // Dark gray
  static const Color subtitleColor = Color(0xFF7A7A7A); // Medium gray
  static const Color borderColor = Color(0xFFD9D9D9); // Light gray

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.nunito(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: GoogleFonts.nunito(color: textColor),
        bodySmall: GoogleFonts.nunito(color: subtitleColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        surface: backgroundColor,
      ),
    );
  }
}
