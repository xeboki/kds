import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color surface;
  final Color surfaceContainer;
  final Color background;
  final Color onSurface;
  final Color onPrimary;
  final Color border;
  final Color shadow;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color disabled;
  final Color onDisabled;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color chipBackground;
  final Color chipForeground;
  final Color tableHeader;

  const AppColorScheme({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.surface,
    required this.surfaceContainer,
    required this.background,
    required this.onSurface,
    required this.onPrimary,
    required this.border,
    required this.shadow,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.disabled,
    required this.onDisabled,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.chipBackground,
    required this.chipForeground,
    required this.tableHeader,
  });

  // Backward compatibility aliases
  Color get textDisabled => onDisabled;
  Color get divider => border;
}

class AppColors {
  // Modern Xeboki theme - matching the website's vibrant, eye-catching design
  static const light = AppColorScheme(
    // Primary Colors - Vibrant Blue (matching Xeboki website)
    primary: Color(0xFF2563eb),            // Blue-600 - Main brand color
    primaryContainer: Color(0xFFdbeafe),   // Blue-100 - Soft blue container
    secondary: Color(0xFF2563EB),          // Blue-600 - Secondary accent (unified with primary)

    // Surface & Background - Clean, Modern
    surface: Color(0xFFffffff),            // Pure white cards
    surfaceContainer: Color(0xFFf8fafc),   // Slate-50 - Very light container
    background: Color(0xFFf1f5f9),         // Slate-100 - Soft background

    // Text & Contrast
    onSurface: Color(0xFF0f172a),          // Slate-900 - Dark text
    onPrimary: Color(0xFFffffff),          // White on primary
    textPrimary: Color(0xFF0f172a),        // Slate-900 - Primary text
    textSecondary: Color(0xFF64748b),      // Slate-500 - Muted text

    // Borders & Shadows - Subtle & Elegant
    border: Color(0xFFe2e8f0),             // Slate-200 - Soft border
    shadow: Color(0x0a000000),             // Very subtle shadow
    inputFill: Color(0xFFffffff),          // White inputs

    // State Colors
    disabled: Color(0xFFe2e8f0),           // Slate-200 - Disabled state
    onDisabled: Color(0xFF94a3b8),         // Slate-400 - Disabled text

    // Semantic Colors - Professional & Clear
    error: Color(0xFFef4444),              // Red-500 - Error
    success: Color(0xFF10b981),            // Emerald-500 - Success
    warning: Color(0xFFf59e0b),            // Amber-500 - Warning
    info: Color(0xFF3b82f6),               // Blue-500 - Info

    // Chips & Tags - Soft & Modern
    chipBackground: Color(0xFFdbeafe),     // Blue-100 - Chip background
    chipForeground: Color(0xFF1e40af),     // Blue-800 - Chip text
    tableHeader: Color(0xFFf8fafc),        // Slate-50 - Table header
  );

  static const dark = AppColorScheme(
    // Primary Colors - Lighter for dark mode
    primary: Color(0xFF60a5fa),            // Blue-400 - Lighter blue for dark
    primaryContainer: Color(0xFF1e3a8a),   // Blue-900 - Dark container
    secondary: Color(0xFF818cf8),          // Indigo-400 - Secondary light

    // Surface & Background - Deep & Modern
    surface: Color(0xFF1e293b),            // Slate-800 - Dark surface
    surfaceContainer: Color(0xFF0f172a),   // Slate-900 - Darker container
    background: Color(0xFF020617),         // Slate-950 - Very dark background

    // Text & Contrast
    onSurface: Color(0xFFf1f5f9),          // Slate-100 - Light text
    onPrimary: Color(0xFF0f172a),          // Dark text on primary
    textPrimary: Color(0xFFf1f5f9),        // Slate-100 - Primary text
    textSecondary: Color(0xFF94a3b8),      // Slate-400 - Muted text

    // Borders & Shadows
    border: Color(0xFF334155),             // Slate-700 - Dark border
    shadow: Color(0x1a000000),             // Darker shadow for depth
    inputFill: Color(0xFF1e293b),          // Slate-800 - Dark inputs

    // State Colors
    disabled: Color(0xFF334155),           // Slate-700 - Disabled
    onDisabled: Color(0xFF64748b),         // Slate-500 - Disabled text

    // Semantic Colors - Lighter for dark mode
    error: Color(0xFFf87171),              // Red-400
    success: Color(0xFF34d399),            // Emerald-400
    warning: Color(0xFFfbbf24),            // Amber-400
    info: Color(0xFF60a5fa),               // Blue-400

    // Chips & Tags
    chipBackground: Color(0xFF1e3a8a),     // Blue-900 - Dark chip
    chipForeground: Color(0xFF93c5fd),     // Blue-300 - Light chip text
    tableHeader: Color(0xFF1e293b),        // Slate-800 - Dark table header
  );

  // Status Colors - Professional & Clear
  static const statusColors = {
    'active': {
      'light': {'bg': Color(0xFFd1fae5), 'fg': Color(0xFF059669)},  // Emerald
      'dark': {'bg': Color(0xFF064e3b), 'fg': Color(0xFF34d399)},
    },
    'expired': {
      'light': {'bg': Color(0xFFfee2e2), 'fg': Color(0xFFdc2626)},  // Red
      'dark': {'bg': Color(0xFF7f1d1d), 'fg': Color(0xFFf87171)},
    },
    'suspended': {
      'light': {'bg': Color(0xFFfef3c7), 'fg': Color(0xFFd97706)},  // Amber
      'dark': {'bg': Color(0xFF78350f), 'fg': Color(0xFFfbbf24)},
    },
    'pending': {
      'light': {'bg': Color(0xFFdbeafe), 'fg': Color(0xFF2563eb)},  // Blue
      'dark': {'bg': Color(0xFF1e3a8a), 'fg': Color(0xFF60a5fa)},
    },
    'paid': {
      'light': {'bg': Color(0xFFd1fae5), 'fg': Color(0xFF059669)},  // Emerald
      'dark': {'bg': Color(0xFF064e3b), 'fg': Color(0xFF34d399)},
    },
    'overdue': {
      'light': {'bg': Color(0xFFfee2e2), 'fg': Color(0xFFdc2626)},  // Red
      'dark': {'bg': Color(0xFF7f1d1d), 'fg': Color(0xFFf87171)},
    },
  };

  static Map<String, Color> getStatusColors(String status, bool isDark) {
    final colors = statusColors[status.toLowerCase()];
    if (colors == null) return {'bg': light.disabled, 'fg': light.onDisabled};

    final themeColors = colors[isDark ? 'dark' : 'light'];
    return {
      'bg': themeColors!['bg']!,
      'fg': themeColors['fg']!,
    };
  }
}

/// Extension on AppColorScheme for glass effects and gradients
extension AppColorSchemeExtensions on AppColorScheme {
  // ===========================================================================
  // GLASSMORPHISM COLORS
  // ===========================================================================

  /// Glass overlay color for glassmorphism effect
  /// Returns a semi-transparent white color based on theme
  Color get glassOverlay {
    // Check if this is a dark theme by comparing surface brightness
    final isDark = surface.computeLuminance() < 0.5;
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.1);
  }

  /// Glass border color for glassmorphism effect
  Color get glassBorder {
    final isDark = surface.computeLuminance() < 0.5;
    return isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.2);
  }

  /// Glass shadow color
  Color get glassShadow {
    final isDark = surface.computeLuminance() < 0.5;
    return isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  // ===========================================================================
  // GRADIENT PRESETS
  // ===========================================================================

  /// Primary gradient (left to right)
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Primary gradient (vertical)
  LinearGradient get primaryGradientVertical => LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Success gradient
  LinearGradient get successGradient => LinearGradient(
        colors: [success, success.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Warning gradient
  LinearGradient get warningGradient => LinearGradient(
        colors: [warning, warning.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Error gradient
  LinearGradient get errorGradient => LinearGradient(
        colors: [error, error.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Info gradient
  LinearGradient get infoGradient => LinearGradient(
        colors: [info, info.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Surface gradient (subtle)
  LinearGradient get surfaceGradient => LinearGradient(
        colors: [surface, surfaceContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Shimmer gradient for skeleton loading
  LinearGradient get shimmerGradient {
    final isDark = surface.computeLuminance() < 0.5;
    if (isDark) {
      return LinearGradient(
        colors: [
          surfaceContainer,
          surfaceContainer.withValues(alpha: 0.5),
          surfaceContainer,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [
          surface,
          surface.withValues(alpha: 0.5),
          surface,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  // ===========================================================================
  // GLOW EFFECTS
  // ===========================================================================

  /// Primary glow color (for active states)
  Color get primaryGlow => primary.withValues(alpha: 0.3);

  /// Success glow color
  Color get successGlow => success.withValues(alpha: 0.3);

  /// Error glow color
  Color get errorGlow => error.withValues(alpha: 0.3);

  /// Warning glow color
  Color get warningGlow => warning.withValues(alpha: 0.3);

  // ===========================================================================
  // OVERLAY COLORS
  // ===========================================================================

  /// Hover overlay color
  Color get hoverOverlay {
    final isDark = surface.computeLuminance() < 0.5;
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
  }

  /// Pressed/Active overlay color
  Color get activeOverlay {
    final isDark = surface.computeLuminance() < 0.5;
    return isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
  }

  /// Focus overlay color
  Color get focusOverlay => primary.withValues(alpha: 0.1);

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get a lighter shade of a color
  Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  /// Get a darker shade of a color
  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }
}
