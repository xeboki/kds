import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KDS is always dark — kitchen environments demand it.
class KdsTheme {
  KdsTheme._();

  static const Color primary     = Color(0xFF6366F1); // Xeboki indigo
  static const Color surface     = Color(0xFF1A1A2E);
  static const Color surfaceCard = Color(0xFF16213E);
  static const Color surfaceLow  = Color(0xFF0F3460);

  // Order age colours — industry standard traffic light
  static const Color ageOk      = Color(0xFF22C55E); // green  < 8 min
  static const Color ageAmber   = Color(0xFFF59E0B); // amber  8–15 min
  static const Color ageRed     = Color(0xFFEF4444); // red    > 15 min
  static const Color ageUrgent  = Color(0xFFDC2626); // deep red > 25 min

  // Priority colours
  static const Color priorityNormal = Color(0xFF22C55E);
  static const Color priorityHigh   = Color(0xFFF59E0B);
  static const Color priorityUrgent = Color(0xFFEF4444);

  // Status colours
  static const Color statusPending   = Color(0xFF94A3B8);
  static const Color statusPreparing = Color(0xFF3B82F6);
  static const Color statusReady     = Color(0xFF22C55E);
  static const Color statusBumped    = Color(0xFF64748B);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary:   primary,
        secondary: const Color(0xFF818CF8),
        surface:   surfaceCard,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
