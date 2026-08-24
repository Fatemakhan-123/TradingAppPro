import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8); // Light Indigo
  static const Color primaryDark = Color(0xFF4F46E5); // Dark Indigo
  static final Color blackColor = Colors.black;
  static final Color whiteColor = Colors.white;

  // Add this line for transparent
  static const Color transparent = Colors.transparent;

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF10B981); // Emerald Green
  static const Color accentColor = Color(0xFFF59E0B); // Amber

  // Background Colors
  static const Color bgDark = Color(0xFF0F172A); // Very dark blue-gray
  static const Color bgLight = Color(0xFFF8FAFC); // Very light gray
  static const Color cardDark = Color(0xFF1E293B); // Dark slate
  static const Color cardLight = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFFFFFFF); // White
  static const Color textDarkSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color textLightPrimary = Color(0xFF0F172A); // Near black
  static const Color textLightSecondary = Color(0xFF64748B); // Medium gray

  // Status Colors
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color errorColor = Color(0xFEF4433); // Rose
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get colors based on theme
  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textDarkPrimary : textLightPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textDarkSecondary : textLightSecondary;
  }
}
