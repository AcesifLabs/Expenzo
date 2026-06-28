import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

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
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: cardShadow,
        shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: const OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: inputBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _cardBorderRadius,
          borderSide: BorderSide(color: inputFocused, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: buttonFg,
          padding: _buttonPadding,
          elevation: 0,
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
        elevation: 0,
        shape: const CircleBorder(),
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
        side: BorderSide.none,
      ),
      datePickerTheme: DatePickerThemeData(
        rangeSelectionBackgroundColor: buttonBg.withAlpha(20),
        todayBorder: BorderSide(color: outlineBorder),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return buttonFg;
          return null;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: navSelected,
        unselectedItemColor: navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: navIndicator,
        elevation: 0,
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
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.primary,
      error: AppColors.errorDark,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.backgroundDark,
      onSecondary: AppColors.backgroundDark,
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
  );
}
