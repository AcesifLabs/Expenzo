import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Shared shape values
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(12));
  static const _buttonBorderRadius = BorderRadius.all(Radius.circular(12));
  static const _dialogBorderRadius = BorderRadius.all(Radius.circular(16));
  static const _chipBorderRadius = BorderRadius.all(Radius.circular(8));
  static const _snackBorderRadius = BorderRadius.all(Radius.circular(8));
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );

  // Shared text theme — identical for both modes
  static final TextTheme _textTheme = TextTheme(
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

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color appBarBg,
    required Color appBarFg,
    required Color cardColor,
    required Color cardShadow,
    required Color inputFill,
    required Color inputBorder,
    required Color inputFocused,
    required Color buttonBg,
    required Color buttonFg,
    required Color outlineFg,
    required Color outlineBorder,
    required Color textFg,
    required Color fabBg,
    required Color fabFg,
    required Color navBg,
    required Color navSelected,
    required Color navUnselected,
    required Color navIndicator,
    required Color snackBg,
    required Color snackContent,
    required Color dialogBg,
    required Color chipBg,
    required Color chipLabel,
    required Color dividerColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: cardShadow,
        shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: const OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: inputFocused, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: buttonFg,
          padding: _buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: _buttonBorderRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: outlineFg,
          side: BorderSide(color: outlineBorder),
          padding: _buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: _buttonBorderRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: textFg),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabBg,
        foregroundColor: fabFg,
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 0.5),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBg,
        shape: const RoundedRectangleBorder(borderRadius: _dialogBorderRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBg,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: snackContent,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: _snackBorderRadius),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBg,
        labelStyle: AppTypography.labelMedium.copyWith(color: chipLabel),
        shape: const RoundedRectangleBorder(borderRadius: _chipBorderRadius),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: navSelected,
        unselectedItemColor: navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: navIndicator,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTypography.labelSmall.copyWith(
            color: states.contains(WidgetState.selected)
                ? navSelected
                : navUnselected,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? navSelected
                : navUnselected,
          );
        }),
      ),
    );
  }

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
    ),
    scaffoldBg: AppColors.backgroundLight,
    appBarBg: AppColors.surfaceLight,
    appBarFg: AppColors.textPrimaryLight,
    cardColor: AppColors.surfaceLight,
    cardShadow: AppColors.primary.withAlpha(30),
    inputFill: AppColors.surfaceLight,
    inputBorder: AppColors.textSecondaryLight,
    inputFocused: AppColors.primary,
    buttonBg: AppColors.primary,
    buttonFg: Colors.white,
    outlineFg: AppColors.primary,
    outlineBorder: AppColors.primary,
    textFg: AppColors.primary,
    fabBg: AppColors.primary,
    fabFg: Colors.white,
    navBg: AppColors.surfaceLight,
    navSelected: AppColors.primary,
    navUnselected: AppColors.textSecondaryLight,
    navIndicator: AppColors.primary.withAlpha(30),
    snackBg: AppColors.textPrimaryLight,
    snackContent: Colors.white,
    dialogBg: AppColors.surfaceLight,
    chipBg: AppColors.secondary.withAlpha(30),
    chipLabel: AppColors.primary,
    dividerColor: AppColors.textSecondaryLight,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.primary,
      error: AppColors.errorDark,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.backgroundDark,
      onSecondary: Colors.white,
    ),
    scaffoldBg: AppColors.backgroundDark,
    appBarBg: AppColors.surfaceDark,
    appBarFg: AppColors.textPrimaryDark,
    cardColor: AppColors.surfaceDark,
    cardShadow: Colors.black45,
    inputFill: AppColors.surfaceDark,
    inputBorder: AppColors.textSecondaryDark,
    inputFocused: AppColors.secondary,
    buttonBg: AppColors.secondary,
    buttonFg: Colors.white,
    outlineFg: AppColors.secondary,
    outlineBorder: AppColors.secondary,
    textFg: AppColors.secondary,
    fabBg: AppColors.secondary,
    fabFg: Colors.white,
    navBg: AppColors.surfaceDark,
    navSelected: AppColors.secondary,
    navUnselected: AppColors.textSecondaryDark,
    navIndicator: AppColors.secondary.withAlpha(30),
    snackBg: AppColors.surfaceDark,
    snackContent: AppColors.textPrimaryDark,
    dialogBg: AppColors.surfaceDark,
    chipBg: AppColors.primary.withAlpha(30),
    chipLabel: AppColors.secondary,
    dividerColor: AppColors.textSecondaryDark,
  );
}
