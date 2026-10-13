/// The kitchen screen, wearing the till's clothes.
///
/// SPEC-097. This app had its own four-colour palette and a hardcoded dark
/// `ThemeData`, invented separately from Pro's. Same product, two design
/// systems, and no way to tell which was current when either changed.
///
/// `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart` and
/// `app_theme.dart` are now Pro's own files, copied verbatim. What is left
/// here is the part Pro has no equivalent for: what a kitchen needs to say
/// about a ticket's **age**, **priority** and **state**.
///
/// Those are derived from Pro's semantic roles rather than picked again.
/// Pro's `error`, `warning`, `success` and `info` differ between light and
/// dark — deliberately, so they stay legible on either ground — so these take
/// a `BuildContext` for the same reason, instead of being the constants they
/// used to be.
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reads the palette the way every Pro screen does — the brightness in force,
/// not a mode this app decides for itself.
extension KdsColorsX on BuildContext {
  AppColorScheme get appColors => Theme.of(this).brightness == Brightness.light
      ? AppColors.light
      : AppColors.dark;

  /// What the kitchen says about a ticket, in the till's own colours.
  KitchenPalette get kitchen => KitchenPalette(appColors);
}

/// The traffic light a kitchen runs on, mapped onto Pro's semantic roles.
///
/// A kitchen's "late" is Pro's `warning` and its "very late" is Pro's
/// `error` — the same two colours a merchant already reads as caution and
/// trouble everywhere else in the product. Naming them again here, in
/// different hex, is how the two apps came to disagree.
class KitchenPalette {
  const KitchenPalette(this._c);

  final AppColorScheme _c;

  // ── Age ────────────────────────────────────────────────────────────────
  Color get ageOk => _c.success;
  Color get ageAmber => _c.warning;
  Color get ageRed => _c.error;

  /// Past the point where somebody should already have been told.
  ///
  /// The one colour with no role in Pro: there is no "worse than error".
  /// Darkened rather than invented, so it still belongs to the same ramp.
  Color get ageUrgent => Color.alphaBlend(Colors.black.withValues(alpha: 0.25),
      _c.error);

  // ── Priority ───────────────────────────────────────────────────────────
  Color get priorityNormal => _c.success;
  Color get priorityHigh => _c.warning;
  Color get priorityUrgent => _c.error;

  // ── Status ─────────────────────────────────────────────────────────────
  Color get statusPending => _c.textSecondary;
  Color get statusPreparing => _c.info;
  Color get statusReady => _c.success;

  /// Bumped is *done*, so it recedes — the disabled tone, not a colour of
  /// its own.
  Color get statusBumped => _c.onDisabled;
}
