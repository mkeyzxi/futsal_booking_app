// lib/utils/app_styles.dart
import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Color(0xFF42A5F5); // Blue 400
  static const Color secondaryColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
  static const Color textColor = Color(0xFF212121); // Grey 900
  static const Color successColor = Color(0xFF66BB6A); // Green 400
  static const Color errorColor = Color(0xFFEF5350); // Red 400

  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;

  static TextStyle headingStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle subHeadingStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static TextStyle bodyTextStyle = const TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static TextStyle smallTextStyle = const TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}
