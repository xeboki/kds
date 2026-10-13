import 'package:flutter/material.dart';

class AppTextStyleScheme {
  final TextStyle headingXLarge;
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle headingSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle bodyLargeSemiBold;
  final TextStyle bodyMediumSemiBold;
  final TextStyle bodySmallSemiBold;
  final TextStyle caption;
  final TextStyle captionSemiBold;
  final TextStyle overline;

  const AppTextStyleScheme({
    required this.headingXLarge,
    required this.headingLarge,
    required this.headingMedium,
    required this.headingSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.bodyLargeSemiBold,
    required this.bodyMediumSemiBold,
    required this.bodySmallSemiBold,
    required this.caption,
    required this.captionSemiBold,
    required this.overline,
  });

  // Material Design compatible getters
  TextStyle get titleLarge => headingLarge;
  TextStyle get titleMedium => headingMedium;
  TextStyle get headlineMedium => headingMedium;
}

class AppTextStyles {
  static const light = AppTextStyleScheme(
    headingXLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1a1a1a),
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headingLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headingMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
      height: 1.3,
    ),
    headingSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF374151),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF374151),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF6b7280),
      height: 1.4,
    ),
    bodyLargeSemiBold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
      height: 1.5,
    ),
    bodyMediumSemiBold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
      height: 1.5,
    ),
    bodySmallSemiBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
      height: 1.4,
    ),
    caption: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6b7280),
      height: 1.4,
    ),
    captionSemiBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
      height: 1.4,
    ),
    overline: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color(0xFF9ca3af),
      height: 1.6,
      letterSpacing: 0.5,
    ),
  );

  static const dark = AppTextStyleScheme(
    headingXLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Color(0xFFf9fafb),
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headingLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFFf9fafb),
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headingMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFf9fafb),
      height: 1.3,
    ),
    headingSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFf9fafb),
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFFd1d5db),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFd1d5db),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF9ca3af),
      height: 1.4,
    ),
    bodyLargeSemiBold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFf9fafb),
      height: 1.5,
    ),
    bodyMediumSemiBold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFFf9fafb),
      height: 1.5,
    ),
    bodySmallSemiBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFFd1d5db),
      height: 1.4,
    ),
    caption: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF9ca3af),
      height: 1.4,
    ),
    captionSemiBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFFd1d5db),
      height: 1.4,
    ),
    overline: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6b7280),
      height: 1.6,
      letterSpacing: 0.5,
    ),
  );
}
