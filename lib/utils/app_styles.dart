// // lib/utils/app_styles.dart

// import 'package:flutter/material.dart';

// class AppStyles {
//   static const Color primaryColor = Color(0xFF42A5F5); // Blue 400
//   static const Color secondaryColor = Color(0xFFFFC107); // Amber
//   static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
//   static const Color textColor = Color(0xFF212121); // Grey 900
//   static const Color successColor = Color(0xFF66BB6A); // Green 400
//   static const Color errorColor = Color(0xFFEF5350); // Red 400

//   static const double defaultPadding = 16.0;
//   static const double defaultBorderRadius = 8.0;

//   static TextStyle headingStyle = const TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: textColor,
//   );

//   static TextStyle subHeadingStyle = const TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.w600,
//     color: textColor,
//   );

//   static TextStyle bodyTextStyle = const TextStyle(
//     fontSize: 16,
//     color: textColor,
//   );

//   static TextStyle smallTextStyle = const TextStyle(
//     fontSize: 14,
//     color: textColor,
//   );

//   static BoxDecoration cardDecoration = BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(defaultBorderRadius),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.grey.withOpacity(0.1),
//         spreadRadius: 2,
//         blurRadius: 5,
//         offset: Offset(0, 3), // changes position of shadow
//       ),
//     ],
//   );
// }
// lib/utils/app_styles.dart
// lib/utils/app_styles.dart
// lib/utils/app_styles.dart
import 'package:flutter/material.dart';

class AppStyles {
  // --- Colors ---
  static const Color primaryColor = Color(0xFF42A5F5); // Blue 400 (Existing)
  static const Color secondaryColor = Color(0xFFFFC107); // Amber (Existing)
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100 (Existing)
  static const Color textColor = Color(0xFF212121); // Grey 900 (Existing)
  static const Color successColor = Color(0xFF66BB6A); // Green 400 (Existing)
  static const Color errorColor = Color(0xFFEF5350); // Red 400 (Existing)

  // New colors for a more modern palette and semantic use
  static const Color accentColor = Color(
    0xFF34A853,
  ); // A vibrant green for positive actions
  static const Color cardColor = Colors.white; // Explicitly defined card color
  static const Color secondaryTextColor = Color(
    0xFF757575,
  ); // Muted grey for secondary text
  static const Color tertiaryTextColor = Color(
    0xFFBDBDBD,
  ); // Lighter grey for hints/placeholders
  static const Color warningColor = Color(
    0xFFFFA000,
  ); // Orange for pending/warning states
  static const Color infoColor = Color(
    0xFF0288D1,
  ); // Light blue for informational elements

  // --- Spacing / Dimensions ---
  static const double defaultPadding =
      16.0; // Existing base padding. Keep this if you still use it directly.

  // Explicitly defined padding variables for consistent use across components
  static const double paddingSmall = 8.0;
  static const double paddingDefault =
      16.0; // This is the one that was 'not defined' implicitly, now explicit
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // --- Border Radius ---
  static const double defaultBorderRadius = 8.0; // Existing base border radius

  // New granular border radius values
  static const double radiusSmall = 8.0; // Consistent with defaultBorderRadius
  static const double radiusDefault =
      12.0; // Slightly larger for a softer look (This will be used more often)
  static const double radiusLarge = 16.0;
  static const double radiusCircle = 100.0; // For perfectly round elements

  // --- Text Styles ---
  // Existing text styles
  static TextStyle headingStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle subHeadingStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semi-bold
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

  // New text styles for a more defined typographic hierarchy
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: -0.5, // Tighter spacing for large titles
  );

  static const TextStyle headline2 = TextStyle(
    // Added to fill a gap in hierarchy
    fontSize:
        24, // Same as original headingStyle but with more modern properties
    fontWeight: FontWeight.w700,
    color: textColor,
    letterSpacing: -0.4,
  );

  static const TextStyle subtitle1 = TextStyle(
    // Renamed from subHeadingStyle for clarity in new hierarchy
    fontSize: 18, // Same as original subHeadingStyle
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyText1 = TextStyle(
    // Renamed from bodyTextStyle for consistency
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.5, // Improved line height for readability
  );

  static const TextStyle bodyText2 = TextStyle(
    // Smaller body text
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor, // Using secondary text color
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    // Smallest text style for captions, hints
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor,
  );

  static const TextStyle buttonText = TextStyle(
    // Consistent button text style
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // --- Box Decorations ---
  // Existing card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white, // Kept existing white
    borderRadius: BorderRadius.circular(
      defaultBorderRadius,
    ), // Kept existing defaultBorderRadius
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  );

  // New decoration for highlighted cards (e.g., active item in carousel)
  static BoxDecoration highlightCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusLarge), // Using new radiusLarge
    border: Border.all(color: primaryColor, width: 2.0),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.2), // Shadow with primary color tint
        spreadRadius: 2,
        blurRadius: 12, // More pronounced blur
        offset: const Offset(0, 6),
      ),
    ],
  );

  // --- Input Field Decoration Theme ---
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100, // Light grey background for input fields
    contentPadding: const EdgeInsets.symmetric(
      vertical: paddingSmall,
      horizontal: paddingDefault,
    ), // Using new spacing
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        radiusDefault,
      ), // Using new radiusDefault
      borderSide: BorderSide.none, // No border by default
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusDefault),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusDefault),
      borderSide: const BorderSide(
        color: primaryColor,
        width: 2.0,
      ), // Primary color on focus
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusDefault),
      borderSide: const BorderSide(color: errorColor, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusDefault),
      borderSide: const BorderSide(color: errorColor, width: 2.0),
    ),
    hintStyle: const TextStyle(
      color: tertiaryTextColor,
    ), // Using tertiary text color for hints
  );

  // --- Button Styles ---
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingSmall,
    ), // Using new spacing
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        radiusDefault,
      ), // Using new radiusDefault
    ),
    textStyle: buttonText, // Using new buttonText style
    elevation: 3,
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingSmall,
    ), // Using new spacing
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        radiusDefault,
      ), // Using new radiusDefault
    ),
    textStyle: buttonText.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
    ), // Using new buttonText, but colored
  );
}
