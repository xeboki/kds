import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  /// The one corner and the one height every button and field uses.
  ///
  /// Measured off the controls that already looked right — the till's
  /// Shortcuts / Parked / Pay out buttons and Manager's search, location and
  /// status filter fields are all 36 high with an 8px corner. The themes said
  /// 14, a few hand-built bars said 8, and each new screen took whichever it
  /// was copied from, so no two screens agreed. Everything reads these now.
  static const double controlRadius = 8.0;
  static const double controlHeight = 36.0;
  static const double buttonRadius = controlRadius;

  static const String defaultFontFamily = 'Inter';
  static String currentFontFamily = defaultFontFamily;

  static void setFontFamily(String fontFamily) {
    currentFontFamily = fontFamily;
  }

  /// Get light theme (backward compatibility - can be called with or without parentheses)
  static ThemeData light() => lightTheme;

  /// Get dark theme (backward compatibility - can be called with or without parentheses)
  static ThemeData dark() => darkTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: currentFontFamily,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.light.primary,
        primaryContainer: AppColors.light.primaryContainer,
        secondary: AppColors.light.secondary,
        surface: AppColors.light.surface,
        surfaceContainer: AppColors.light.surfaceContainer,
        onSurface: AppColors.light.onSurface,
        onPrimary: AppColors.light.onPrimary,
      ),

      scaffoldBackgroundColor: AppColors.light.background,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.light.surface,
        foregroundColor: AppColors.light.onSurface,
        surfaceTintColor: Colors.transparent,
        // Match the benchmark heading (AppScreenLayout / AppBarTitleRow): 17px
        // w700, no letter-spacing. Detail screens that pass a bare `Text(...)`
        // title inherit this, so a sub-screen heading (e.g. a PO number) reads
        // at the same size as a list-screen title like "Customers" instead of
        // the old 28px default.
        titleTextStyle: AppTextStyles.light.headingLarge.copyWith(
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          letterSpacing: 0,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.light.surface,
        surfaceTintColor: AppColors.light.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),  // Modern, soft radius
          side: BorderSide(
            color: AppColors.light.border,
            width: 1,
          ),
        ),
        shadowColor: AppColors.light.shadow.withValues(alpha: 0.08),
        margin: const EdgeInsets.all(0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          elevation: 0,
          backgroundColor: AppColors.light.primary,
          foregroundColor: AppColors.light.onPrimary,
          disabledBackgroundColor: AppColors.light.disabled,
          disabledForegroundColor: AppColors.light.onDisabled,
          textStyle: AppTextStyles.light.bodyMediumSemiBold.copyWith(
            fontFamily: currentFontFamily,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),  // Softer radius
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shadowColor: AppColors.light.primary.withValues(alpha: 0.2),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.light.onPrimary.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.light.onPrimary.withValues(alpha: 0.2);
              }
              return null;
            },
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          foregroundColor: AppColors.light.primary,
          side: BorderSide(color: AppColors.light.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          foregroundColor: AppColors.light.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),  // Softer radius
          borderSide: BorderSide(color: AppColors.light.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.light.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.light.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.light.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.light.error, width: 2.5),
        ),
        hintStyle: AppTextStyles.light.bodyMedium.copyWith(
          color: AppColors.light.textSecondary,
          fontFamily: currentFontFamily,
        ),
        labelStyle: AppTextStyles.light.bodyMedium.copyWith(
          color: AppColors.light.textSecondary,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.light.tableHeader),
        dataRowColor: WidgetStateProperty.all(AppColors.light.surface),
        headingTextStyle: AppTextStyles.light.bodyMediumSemiBold.copyWith(
          color: AppColors.light.textPrimary,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: AppTextStyles.light.bodyMedium.copyWith(
          color: AppColors.light.textPrimary,
          fontFamily: currentFontFamily,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.light.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.light.chipBackground,
        labelStyle: TextStyle(
          color: AppColors.light.chipForeground,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.light.border,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(
        color: AppColors.light.textSecondary,
        size: 24,
      ),

      // Add Pro-specific extensions
      extensions: const [
        AppSpacing.standard,
        AppRadius.standard,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: currentFontFamily,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.dark.primary,
        primaryContainer: AppColors.dark.primaryContainer,
        secondary: AppColors.dark.secondary,
        surface: AppColors.dark.surface,
        surfaceContainer: AppColors.dark.surfaceContainer,
        onSurface: AppColors.dark.onSurface,
        onPrimary: AppColors.dark.onPrimary,
      ),

      scaffoldBackgroundColor: AppColors.dark.background,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.dark.surface,
        foregroundColor: AppColors.dark.onSurface,
        surfaceTintColor: Colors.transparent,
        // Match the benchmark heading (see light theme): 17px w700 so a
        // sub-screen title reads at the same size as a list-screen title.
        titleTextStyle: AppTextStyles.dark.headingLarge.copyWith(
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          letterSpacing: 0,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.dark.surface,
        surfaceTintColor: AppColors.dark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),  // Modern, soft radius
          side: BorderSide(
            color: AppColors.dark.border,
            width: 1,
          ),
        ),
        shadowColor: AppColors.dark.shadow.withValues(alpha: 0.12),
        margin: const EdgeInsets.all(0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          elevation: 0,
          backgroundColor: AppColors.dark.primary,
          foregroundColor: AppColors.dark.onPrimary,
          disabledBackgroundColor: AppColors.dark.disabled,
          disabledForegroundColor: AppColors.dark.onDisabled,
          textStyle: AppTextStyles.dark.bodyMediumSemiBold.copyWith(
            fontFamily: currentFontFamily,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shadowColor: AppColors.dark.primary.withValues(alpha: 0.2),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.dark.onPrimary.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.dark.onPrimary.withValues(alpha: 0.2);
              }
              return null;
            },
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          foregroundColor: AppColors.dark.primary,
          side: BorderSide(color: AppColors.dark.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          // Web and desktop default to compact density, which shaves 8px off
          // every minimum — a 36px button rendered 28. The height is the token.
          visualDensity: VisualDensity.standard,
          foregroundColor: AppColors.dark.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.dark.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.dark.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.dark.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.dark.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: AppColors.dark.error, width: 2.5),
        ),
        hintStyle: AppTextStyles.dark.bodyMedium.copyWith(
          color: AppColors.dark.textSecondary,
          fontFamily: currentFontFamily,
        ),
        labelStyle: AppTextStyles.dark.bodyMedium.copyWith(
          color: AppColors.dark.textSecondary,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.dark.tableHeader),
        dataRowColor: WidgetStateProperty.all(AppColors.dark.surface),
        headingTextStyle: AppTextStyles.dark.bodyMediumSemiBold.copyWith(
          color: AppColors.dark.textPrimary,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: AppTextStyles.dark.bodyMedium.copyWith(
          color: AppColors.dark.textPrimary,
          fontFamily: currentFontFamily,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dark.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.dark.chipBackground,
        labelStyle: TextStyle(
          color: AppColors.dark.chipForeground,
          fontFamily: currentFontFamily,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.dark.border,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(
        color: AppColors.dark.textSecondary,
        size: 24,
      ),

      // Add Pro-specific extensions
      extensions: const [
        AppSpacing.standard,
        AppRadius.standard,
      ],
    );
  }

  // ===========================================================================
  // BACKWARD COMPATIBILITY - Static Color Getters
  // ===========================================================================
  // These getters provide backward compatibility for code using the old
  // AppTheme.colorName pattern instead of AppColors.light.colorName

  /// Primary brand color - Xeboki blue
  static Color get primaryColor => AppColors.light.primary;

  /// Success state color - emerald green
  static Color get successColor => AppColors.light.success;

  /// Error state color - red
  static Color get errorColor => AppColors.light.error;

  /// Warning state color - amber
  static Color get warningColor => AppColors.light.warning;

  /// Info state color - blue
  static Color get infoColor => AppColors.light.info;

  // Neutral grayscale colors (mapped to closest equivalents in new theme)
  /// Very light gray - Slate-50 equivalent
  static Color get neutral50 => AppColors.light.surfaceContainer;

  /// Light gray - Slate-100 equivalent
  static Color get neutral100 => AppColors.light.background;

  /// Light-medium gray - Slate-200 equivalent
  static Color get neutral200 => AppColors.light.border;

  /// Medium-light gray - Slate-300 equivalent
  static const Color neutral300 = Color(0xFFcbd5e1); // Slate-300

  /// Medium gray - Slate-400 equivalent
  static Color get neutral400 => AppColors.light.onDisabled;

  /// Medium gray - Slate-500 equivalent
  static const Color neutral500 = Color(0xFF64748b); // Slate-500

  /// Medium-dark gray - Slate-600 equivalent (used for secondary text)
  static Color get neutral600 => AppColors.light.textSecondary;

  /// Dark gray - Slate-900 equivalent (used for primary text)
  static Color get neutral900 => AppColors.light.textPrimary;

  // ===========================================================================
  // STATUS COLOR HELPERS
  // ===========================================================================

  /// Get foreground color for a status
  ///
  /// Usage: `AppTheme.statusColor('active')` returns the text color for active status
  static Color statusColor(String status, {bool isDark = false}) {
    final colors = AppColors.getStatusColors(status, isDark);
    return colors['fg']!;
  }

  /// Get background color for a status
  ///
  /// Usage: `AppTheme.statusBackgroundColor('pending')` returns the background color for pending status
  static Color statusBackgroundColor(String status, {bool isDark = false}) {
    final colors = AppColors.getStatusColors(status, isDark);
    return colors['bg']!;
  }
}
