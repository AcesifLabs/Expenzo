import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class _ThemeColors {
  final Brightness brightness;
  final ColorScheme colorScheme;
  final Color scaffoldBg;
  final Color appBarBg;
  final Color appBarFg;
  final Color cardColor;
  final Color cardShadow;
  final Color inputFill;
  final Color inputBorder;
  final Color inputFocused;
  final Color buttonBg;
  final Color buttonFg;
  final Color outlineFg;
  final Color outlineBorder;
  final Color textFg;
  final Color fabBg;
  final Color fabFg;
  final Color navBg;
  final Color navSelected;
  final Color navUnselected;
  final Color navIndicator;
  final Color snackBg;
  final Color snackContent;
  final Color dialogBg;
  final Color chipBg;
  final Color chipLabel;
  final Color dividerColor;
  final AppPalette palette;

  const _ThemeColors({
    required this.brightness,
    required this.colorScheme,
    required this.scaffoldBg,
    required this.appBarBg,
    required this.appBarFg,
    required this.cardColor,
    required this.cardShadow,
    required this.inputFill,
    required this.inputBorder,
    required this.inputFocused,
    required this.buttonBg,
    required this.buttonFg,
    required this.outlineFg,
    required this.outlineBorder,
    required this.textFg,
    required this.fabBg,
    required this.fabFg,
    required this.navBg,
    required this.navSelected,
    required this.navUnselected,
    required this.navIndicator,
    required this.snackBg,
    required this.snackContent,
    required this.dialogBg,
    required this.chipBg,
    required this.chipLabel,
    required this.dividerColor,
    required this.palette,
  });
}

class AppTheme {
  static const _cardBorderRadius = BorderRadius.all(
    Radius.circular(AppSpacing.radiusCard),
  );
  static const _controlBorderRadius = BorderRadius.all(
    Radius.circular(AppSpacing.radiusControl),
  );
  static const _sheetBorderRadius = BorderRadius.all(
    Radius.circular(AppSpacing.radiusSheet),
  );
  static const _pillBorderRadius = BorderRadius.all(
    Radius.circular(AppSpacing.radiusPill),
  );
  static const _light = AppPalette.light;
  static const _dark = AppPalette.dark;
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  static final ThemeData _lightTheme = _buildTheme(
    _ThemeColors(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _light.brand,
        onPrimary: Colors.white,
        primaryContainer: _light.brandFill,
        onPrimaryContainer: _light.onBrandFill,
        secondary: _light.accent,
        onSecondary: Colors.white,
        secondaryContainer: _light.accentFill,
        onSecondaryContainer: const Color(0xFF342C49),
        tertiary: _light.info,
        onTertiary: Colors.white,
        error: _light.expense,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF410002),
        surface: _light.surface,
        onSurface: _light.textPrimary,
        onSurfaceVariant: _light.textSecondary,
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF7F7FA),
        surfaceContainer: const Color(0xFFF1F1F4),
        surfaceContainerHigh: _light.surfaceHigh,
        surfaceContainerHighest: const Color(0xFFE5E5EA),
        surfaceTint: _light.brand,
        outline: const Color(0xFF7A757F),
        outlineVariant: const Color(0xFFCAC4CF),
      ),
      scaffoldBg: _light.bg,
      appBarBg: _light.surface,
      appBarFg: _light.textPrimary,
      cardColor: _light.surface,
      cardShadow: Colors.black.withAlpha(10),

      inputFill: _light.bg,
      inputBorder: _light.inputStroke,
      inputFocused: _light.brand,
      buttonBg: _light.brandFill,
      buttonFg: _light.onBrandFill,
      outlineFg: _light.brand,
      outlineBorder: _light.brand.withAlpha(80),
      textFg: _light.brand,
      fabBg: _light.brandFill,
      fabFg: _light.onBrandFill,
      navBg: _light.surface,
      navSelected: _light.brand,
      navUnselected: _light.textSecondary,
      navIndicator: _light.brandFill.withAlpha(60),
      snackBg: _light.textPrimary,
      snackContent: Colors.white,
      dialogBg: _light.surface,
      chipBg: _light.accentFill.withAlpha(60),
      chipLabel: _light.accent,
      dividerColor: _light.divider,
      palette: _light,
    ),
  );

  static final ThemeData _darkTheme = _buildTheme(
    _ThemeColors(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _dark.brand,
        onPrimary: _dark.onBrandFill,
        primaryContainer: _dark.brandFill,
        onPrimaryContainer: _dark.onBrandFill,
        secondary: _dark.accent,
        onSecondary: _dark.onAccentFill,
        secondaryContainer: const Color(0xFF4B4363),
        onSecondaryContainer: const Color(0xFFEDE1FF),
        tertiary: _dark.info,
        onTertiary: _dark.bg,
        error: _dark.expense,
        onError: _dark.bg,
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: _dark.surface,
        onSurface: _dark.textPrimary,
        onSurfaceVariant: _dark.textSecondary,
        surfaceTint: _dark.brand,
        outline: const Color(0xFF948F97),
        outlineVariant: const Color(0xFF49454D),
      ),
      scaffoldBg: _dark.bg,
      appBarBg: _dark.surface,
      appBarFg: _dark.textPrimary,
      cardColor: _dark.surface,
      cardShadow: Colors.black45,
      inputFill: _dark.surfaceHigh,
      inputBorder: _dark.inputStroke,
      inputFocused: _dark.brand,
      buttonBg: _dark.brandFill,
      buttonFg: _dark.onBrandFill,
      outlineFg: _dark.brand,
      outlineBorder: _dark.brand.withAlpha(80),
      textFg: _dark.brand,
      fabBg: _dark.brandFill,
      fabFg: _dark.onBrandFill,
      navBg: _dark.surface,
      navSelected: _dark.brand,
      navUnselected: _dark.textSecondary,
      navIndicator: _dark.brandFill.withAlpha(25),
      snackBg: _dark.surface,
      snackContent: _dark.textPrimary,
      dialogBg: _dark.surface,
      chipBg: _dark.accentFill.withAlpha(25),
      chipLabel: _dark.accent,
      dividerColor: _dark.divider,
      palette: _dark,
    ),
  );

  static ThemeData get lightTheme => _lightTheme;

  static ThemeData get darkTheme => _darkTheme;

  AppTheme._();

  static ThemeData _buildTheme(_ThemeColors c) {
    final scheme = c.colorScheme;
    final primaryWithAlpha40 = scheme.primary.withAlpha(40);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.scaffoldBg,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme(c),
      cardTheme: _cardTheme(c),
      inputDecorationTheme: _inputTheme(c),
      elevatedButtonTheme: _elevatedButtonTheme(c),
      outlinedButtonTheme: _outlinedButtonTheme(c),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.textFg),
      ),
      floatingActionButtonTheme: _fabTheme(c),
      dividerTheme: DividerThemeData(color: c.dividerColor, thickness: 0.5),
      dialogTheme: _dialogTheme(c),
      snackBarTheme: _snackBarTheme(c),
      chipTheme: _chipTheme(c),
      switchTheme: _switchTheme(c),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: primaryWithAlpha40,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
      ),
      datePickerTheme: _datePickerTheme(c),
      bottomNavigationBarTheme: _bottomNavTheme(c),
      navigationBarTheme: _navBarTheme(c),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        dragHandleColor: scheme.onSurface.withAlpha(60),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
      ),
      extensions: [c.palette],
    );
  }

  // Solid brand thumb on a faint brand track, so the on state has contrast.
  // Disabled switches keep Material's defaults.
  static SwitchThemeData _switchTheme(_ThemeColors c) {
    final palette = c.palette;

    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;

        return states.contains(WidgetState.selected)
            ? palette.brand
            : palette.toggleKnob;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;

        return states.contains(WidgetState.selected)
            ? palette.brand.withAlpha(0x40)
            : palette.toggleTrack;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;

        return null;
      }),
    );
  }

  static AppBarTheme _appBarTheme(_ThemeColors c) => AppBarTheme(
    backgroundColor: c.appBarBg,
    foregroundColor: c.appBarFg,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0.5,
  );

  static CardThemeData _cardTheme(_ThemeColors c) => CardThemeData(
    color: c.cardColor,
    elevation: 0,
    shadowColor: c.cardShadow,
    shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
  );

  static InputDecorationTheme _inputTheme(_ThemeColors c) =>
      InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        border: const OutlineInputBorder(
          borderRadius: _controlBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _controlBorderRadius,
          borderSide: BorderSide(color: c.inputBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _controlBorderRadius,
          borderSide: BorderSide(color: c.inputFocused, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(_ThemeColors c) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.buttonBg,
          foregroundColor: c.buttonFg,
          padding: _buttonPadding,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: _controlBorderRadius,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(_ThemeColors c) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.outlineFg,
          side: BorderSide(color: c.outlineBorder),
          padding: _buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: _controlBorderRadius,
          ),
        ),
      );

  static FloatingActionButtonThemeData _fabTheme(_ThemeColors c) =>
      FloatingActionButtonThemeData(
        backgroundColor: c.fabBg,
        foregroundColor: c.fabFg,
        elevation: 0,

        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + AppSpacing.xs,
        ),
      );

  static DialogThemeData _dialogTheme(_ThemeColors c) => DialogThemeData(
    backgroundColor: c.dialogBg,
    shape: const RoundedRectangleBorder(borderRadius: _sheetBorderRadius),
  );

  static SnackBarThemeData _snackBarTheme(_ThemeColors c) => SnackBarThemeData(
    backgroundColor: c.snackBg,
    contentTextStyle: AppTypography.bodyMedium.copyWith(color: c.snackContent),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(borderRadius: _controlBorderRadius),
  );

  static ChipThemeData _chipTheme(_ThemeColors c) => ChipThemeData(
    backgroundColor: c.chipBg,
    labelStyle: AppTypography.labelMedium.copyWith(color: c.chipLabel),
    shape: const RoundedRectangleBorder(borderRadius: _pillBorderRadius),
    side: BorderSide.none,
  );

  static DatePickerThemeData _datePickerTheme(_ThemeColors c) =>
      DatePickerThemeData(
        rangeSelectionBackgroundColor: c.buttonBg.withAlpha(20),
        todayBorder: BorderSide(color: c.outlineBorder),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.buttonFg;

          return null;
        }),
      );

  static BottomNavigationBarThemeData _bottomNavTheme(_ThemeColors c) =>
      BottomNavigationBarThemeData(
        backgroundColor: c.navBg,
        selectedItemColor: c.navSelected,
        unselectedItemColor: c.navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static NavigationBarThemeData _navBarTheme(_ThemeColors c) =>
      NavigationBarThemeData(
        backgroundColor: c.navBg,
        indicatorColor: c.navIndicator,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTypography.labelSmall.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.navSelected
                : c.navUnselected,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.navSelected
                : c.navUnselected,
          );
        }),
      );
}
