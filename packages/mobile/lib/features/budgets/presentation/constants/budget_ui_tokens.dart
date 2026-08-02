import 'package:flutter/material.dart';

/// Design tokens from expenzo.pen shared by budget screens.
abstract final class BudgetUiTokens {
  static const Color bg = Color(0xFF141315);
  static const Color surface = Color(0xFF1C1B1D);
  static const Color inputFill = Color(0xFF201F21);
  static const Color inputStroke = Color(0x208E8E93);
  static const Color primary = Color(0xFFD1C4E9);
  static const Color onPrimary = Color(0xFF141315);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFCCCCCC);
  static const Color toggleTrack = Color(0xFF363437);
  static const Color toggleKnob = Color(0xFF8E8E93);
  static const Color error = Color(0xFFF48FB1);
  static const Color progressTrack = Color(0xFF2B292C);

  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(14),
  );
}
