import 'package:flutter/material.dart';
import 'app_colors.dart';
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
  });
}

class AppTheme {
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(10));
  static const _buttonBorderRadius = BorderRadius.all(Radius.circular(8));
  static const _dialogBorderRadius = BorderRadius.all(Radius.circular(10));
  static const _chipBorderRadius = BorderRadius.all(Radius.circular(6));
  static const _snackBorderRadius = BorderRadius.all(Radius.circular(8));
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

  static ThemeData get lightTheme => _buildTheme(
    _ThemeColors(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
        surfaceTint: AppColors.primary,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        primaryContainer: Color(0xFFEDE1FF),
        onPrimaryContainer: Color(0xFF342C49),
        secondaryContainer: Color(0xFFA2D3A4),
        onSecondaryContainer: Color(0xFF0A3817),
        tertiary: Color(0xFFB3C9FF),
        outline: Color(0xFF948F97),
        outlineVariant: Color(0xFF49454D),
      ),
      scaffoldBg: AppColors.backgroundLight,
      appBarBg: AppColors.surfaceLight,
      appBarFg: AppColors.textPrimaryLight,
      cardColor: AppColors.surfaceLight,
      cardShadow: Colors.black.withAlpha(10),
      inputFill: AppColors.backgroundLight,
      inputBorder: AppColors.textSecondaryLight.withAlpha(60),
      inputFocused: AppColors.primary,
      buttonBg: AppColors.primary,
      buttonFg: AppColors.onPrimary,
      outlineFg: AppColors.primary,
      outlineBorder: AppColors.primary.withAlpha(80),
      textFg: AppColors.primary,
      fabBg: AppColors.primary,
      fabFg: AppColors.onPrimary,
      navBg: AppColors.surfaceLight,
      navSelected: AppColors.primary,
      navUnselected: AppColors.textSecondaryLight,
      navIndicator: AppColors.primary.withAlpha(25),
      snackBg: AppColors.textPrimaryLight,
      snackContent: Colors.white,
      dialogBg: AppColors.surfaceLight,
      chipBg: AppColors.primary.withAlpha(20),
      chipLabel: AppColors.primary,
      dividerColor: AppColors.textSecondaryLight.withAlpha(40),
    ),
  );

  static ThemeData get darkTheme => _buildTheme(
    _ThemeColors(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondary,
        secondary: AppColors.primary,
        error: AppColors.errorDark,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.backgroundDark,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
        surfaceTint: AppColors.secondary,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        primaryContainer: Color(0xFF4B4363),
        onPrimaryContainer: Color(0xFFEDE1FF),
        secondaryContainer: Color(0xFF1E5730),
        onSecondaryContainer: Color(0xFFA2D3A4),
        tertiary: Color(0xFF6D8ECF),
        outline: Color(0xFF948F97),
        outlineVariant: Color(0xFF49454D),
      ),
      scaffoldBg: AppColors.backgroundDark,
      appBarBg: AppColors.surfaceDark,
      appBarFg: AppColors.textPrimaryDark,
      cardColor: AppColors.surfaceDark,
      cardShadow: Colors.black45,
      inputFill: Color(0xFF2C2C2E),
      inputBorder: AppColors.textSecondaryDark.withAlpha(40),
      inputFocused: AppColors.secondary,
      buttonBg: AppColors.secondary,
      buttonFg: AppColors.backgroundDark,
      outlineFg: AppColors.secondary,
      outlineBorder: AppColors.secondary.withAlpha(80),
      textFg: AppColors.secondary,
      fabBg: AppColors.secondary,
      fabFg: Colors.white,
      navBg: AppColors.surfaceDark,
      navSelected: AppColors.secondary,
      navUnselected: AppColors.textSecondaryDark,
      navIndicator: AppColors.secondary.withAlpha(25),
      snackBg: AppColors.surfaceDark,
      snackContent: AppColors.textPrimaryDark,
      dialogBg: AppColors.surfaceDark,
      chipBg: AppColors.secondary.withAlpha(25),
      chipLabel: AppColors.secondary,
      dividerColor: AppColors.textSecondaryDark.withAlpha(40),
    ),
  );

  AppTheme._();

  static ThemeData _buildTheme(_ThemeColors c) {
    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: c.colorScheme,
      scaffoldBackgroundColor: c.scaffoldBg,
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return c.colorScheme.primary;
          return null;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.colorScheme.primary,
        linearTrackColor: c.colorScheme.primary.withAlpha(40),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      datePickerTheme: _datePickerTheme(c),
      bottomNavigationBarTheme: _bottomNavTheme(c),
      navigationBarTheme: _navBarTheme(c),
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
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: c.inputBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
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
            borderRadius: _buttonBorderRadius,
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
            borderRadius: _buttonBorderRadius,
          ),
        ),
      );

  static FloatingActionButtonThemeData _fabTheme(_ThemeColors c) =>
      FloatingActionButtonThemeData(
        backgroundColor: c.fabBg,
        foregroundColor: c.fabFg,
        elevation: 0,
        shape: const CircleBorder(),
      );

  static DialogThemeData _dialogTheme(_ThemeColors c) => DialogThemeData(
    backgroundColor: c.dialogBg,
    shape: const RoundedRectangleBorder(borderRadius: _dialogBorderRadius),
  );

  static SnackBarThemeData _snackBarTheme(_ThemeColors c) => SnackBarThemeData(
    backgroundColor: c.snackBg,
    contentTextStyle: AppTypography.bodyMedium.copyWith(color: c.snackContent),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(borderRadius: _snackBorderRadius),
  );

  static ChipThemeData _chipTheme(_ThemeColors c) => ChipThemeData(
    backgroundColor: c.chipBg,
    labelStyle: AppTypography.labelMedium.copyWith(color: c.chipLabel),
    shape: const RoundedRectangleBorder(borderRadius: _chipBorderRadius),
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
