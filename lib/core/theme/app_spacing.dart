import 'package:flutter/material.dart';

/// App spacing constants - Theme extension
class AppSpacing extends ThemeExtension<AppSpacing> {
  // Spacing values (4px increments)
  final double xs;    // 4px
  final double sm;    // 8px
  final double md;    // 12px
  final double lg;    // 16px
  final double xl;    // 24px
  final double xxl;   // 32px
  final double xxxl;  // 48px

  const AppSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
    this.xxxl = 48,
  });

  static const standard = AppSpacing();

  // Backward compatibility aliases
  double get paddingMD => md;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;

    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
      xxl: lerpDouble(xxl, other.xxl, t) ?? xxl,
      xxxl: lerpDouble(xxxl, other.xxxl, t) ?? xxxl,
    );
  }

  // Helper method for lerping doubles
  double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a + (b - a) * t;
  }
}

/// App border radius constants - Theme extension
class AppRadius extends ThemeExtension<AppRadius> {
  final double sm;   // 4px
  final double md;   // 8px
  final double lg;   // 12px
  final double xl;   // 16px
  final double xxl;  // 24px
  final double full; // 9999px (circular)

  const AppRadius({
    this.sm = 4,
    this.md = 8,
    this.lg = 12,
    this.xl = 16,
    this.xxl = 24,
    this.full = 9999,
  });

  static const standard = AppRadius();

  @override
  AppRadius copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? full,
  }) {
    return AppRadius(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      full: full ?? this.full,
    );
  }

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;

    return AppRadius(
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
      xxl: lerpDouble(xxl, other.xxl, t) ?? xxl,
      full: lerpDouble(full, other.full, t) ?? full,
    );
  }

  double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a + (b - a) * t;
  }
}
