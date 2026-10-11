import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide color roles that the Material [ColorScheme] has no slot for.
///
/// Registered on both [ThemeData]s in `app_theme.dart`; read it with
/// `context.palette` so screens follow the light/dark setting. Values are
/// documented in DESIGN.md ("Dark palette" / "Light palette").
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg;
  final Color surface;

  /// Raised fills on top of [surface]: chips, keypad keys, icon tiles.
  final Color surfaceHigh;
  final Color inputFill;
  final Color inputStroke;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Brand mint for text and icons: links, selected tab, focus.
  final Color brand;

  /// Brand mint for filled surfaces: primary buttons, the add button.
  final Color brandFill;
  final Color onBrandFill;

  /// Secondary lavender for text and icons: chart highlights, tags.
  final Color accent;

  /// Secondary lavender for filled backgrounds: chips, info tiles.
  final Color accentFill;
  final Color onAccentFill;
  final Color expense;
  final Color income;
  final Color warning;
  final Color info;
  final Color progressTrack;
  final Color toggleTrack;
  final Color toggleKnob;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.inputFill,
    required this.inputStroke,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brand,
    required this.brandFill,
    required this.onBrandFill,
    required this.accent,
    required this.accentFill,
    required this.onAccentFill,
    required this.expense,
    required this.income,
    required this.warning,
    required this.info,
    required this.progressTrack,
    required this.toggleTrack,
    required this.toggleKnob,
  });

  /// Error text and icons share the expense rose.
  Color get error => expense;

  static const AppPalette dark = AppPalette(
    bg: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceHigh: Color(0xFF2B292C),
    inputFill: Color(0xFF201F21),
    inputStroke: Color(0x208E8E93),
    divider: Color(0x208E8E93),
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: Color(0xFFCCCCCC),
    brand: AppColors.brandMint,
    brandFill: AppColors.brandMint,
    onBrandFill: AppColors.backgroundDark,
    accent: AppColors.lavender,
    accentFill: AppColors.lavender,
    onAccentFill: AppColors.backgroundDark,
    expense: AppColors.expenseDark,
    income: Color(0xFF80CBC4),
    warning: AppColors.warningDark,
    info: Color(0xFF90CAF9),
    progressTrack: Color(0xFF2B292C),
    toggleTrack: Color(0xFF363437),
    toggleKnob: Color(0xFF8E8E93),
  );

  // Text roles reach at least 4.5:1 on both bg and surface.
  static const AppPalette light = AppPalette(
    bg: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceHigh: Color(0xFFECEBF0),
    inputFill: AppColors.surfaceLight,
    inputStroke: Color(0x3C8E8E93),
    divider: Color(0x1F000000),
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: Color(0xFF6C6C70),
    textTertiary: Color(0xFF636366),
    brand: Color(0xFF2E6B3A),
    brandFill: AppColors.brandMint,
    onBrandFill: Color(0xFF10301A),
    accent: Color(0xFF635979),
    accentFill: AppColors.lavender,
    onAccentFill: AppColors.textPrimaryLight,
    expense: Color(0xFFC2185B),
    income: Color(0xFF00796B),
    warning: Color(0xFFA15F00),
    info: Color(0xFF1565C0),
    progressTrack: Color(0xFFE5E5EA),
    toggleTrack: Color(0xFFE5E5EA),
    toggleKnob: Color(0xFF8E8E93),
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceHigh,
    Color? inputFill,
    Color? inputStroke,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brand,
    Color? brandFill,
    Color? onBrandFill,
    Color? accent,
    Color? accentFill,
    Color? onAccentFill,
    Color? expense,
    Color? income,
    Color? warning,
    Color? info,
    Color? progressTrack,
    Color? toggleTrack,
    Color? toggleKnob,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      inputFill: inputFill ?? this.inputFill,
      inputStroke: inputStroke ?? this.inputStroke,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brand: brand ?? this.brand,
      brandFill: brandFill ?? this.brandFill,
      onBrandFill: onBrandFill ?? this.onBrandFill,
      accent: accent ?? this.accent,
      accentFill: accentFill ?? this.accentFill,
      onAccentFill: onAccentFill ?? this.onAccentFill,
      expense: expense ?? this.expense,
      income: income ?? this.income,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      progressTrack: progressTrack ?? this.progressTrack,
      toggleTrack: toggleTrack ?? this.toggleTrack,
      toggleKnob: toggleKnob ?? this.toggleKnob,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;

    return AppPalette(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceHigh: mix(surfaceHigh, other.surfaceHigh),
      inputFill: mix(inputFill, other.inputFill),
      inputStroke: mix(inputStroke, other.inputStroke),
      divider: mix(divider, other.divider),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      brand: mix(brand, other.brand),
      brandFill: mix(brandFill, other.brandFill),
      onBrandFill: mix(onBrandFill, other.onBrandFill),
      accent: mix(accent, other.accent),
      accentFill: mix(accentFill, other.accentFill),
      onAccentFill: mix(onAccentFill, other.onAccentFill),
      expense: mix(expense, other.expense),
      income: mix(income, other.income),
      warning: mix(warning, other.warning),
      info: mix(info, other.info),
      progressTrack: mix(progressTrack, other.progressTrack),
      toggleTrack: mix(toggleTrack, other.toggleTrack),
      toggleKnob: mix(toggleKnob, other.toggleKnob),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// The [AppPalette] for the active theme. Falls back to [AppPalette.dark]
  /// when no app theme is above this context (e.g. a bare test widget).
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
