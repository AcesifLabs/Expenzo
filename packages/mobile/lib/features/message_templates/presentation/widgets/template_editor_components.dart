import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';

/// Step state for the progress indicator.
enum _StepDotState { completed, active, inactive }

/// A horizontal step progress indicator with dots connected by lines.
///
/// [currentStep] is 1-based. Steps before [currentStep] are shown as
/// completed (green), the current step is active (purple), and steps
/// after are inactive (dimmed).
class StepProgressIndicator extends StatelessWidget {
  static const _completedColor = AppColors.secondary; // #A2D3A4
  static const _activeColor = AppColors.primary; // #D1C4E9
  static const _inactiveColor = Color(0xFF8E8E93);

  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  _StepDotState _stateFor(int step) {
    if (step < currentStep) return _StepDotState.completed;
    if (step == currentStep) return _StepDotState.active;

    return _StepDotState.inactive;
  }

  Color _colorFor(_StepDotState state) {
    return switch (state) {
      _StepDotState.completed => _completedColor,
      _StepDotState.active => _activeColor,
      _StepDotState.inactive => _inactiveColor.withAlpha(0x40),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 1; i <= totalSteps; i++) ...[
            _StepDot(color: _colorFor(_stateFor(i))),
            if (i < totalSteps)
              _StepLine(
                color: _colorFor(
                  i < currentStep
                      ? _StepDotState.completed
                      : _StepDotState.inactive,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final Color color;

  const _StepDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _StepLine extends StatelessWidget {
  final Color color;

  const _StepLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: color,
      ),
    );
  }
}

/// A dark card that displays a message preview with sender name and body.
class MessagePreviewCard extends StatelessWidget {
  final String senderName;
  final String messageBody;

  const MessagePreviewCard({
    super.key,
    required this.senderName,
    required this.messageBody,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            messageBody,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable chip for selecting a trigger word from an SMS message.
///
/// Displays [word] with two visual states: default (dark background) and
/// selected (purple-tinted background with a purple border).
class TriggerWordChip extends StatelessWidget {
  final String word;
  final bool isSelected;
  final VoidCallback onTap;

  const TriggerWordChip({
    super.key,
    required this.word,
    required this.isSelected,
    required this.onTap,
  });

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.98,
        duration: AppSpacing.durationFast,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppSpacing.durationFast,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(0x20)
                : const Color(0xFF2B292C),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            word,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimaryDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width row for selecting an amount, styled as a card with a radio
/// button and the amount value.
///
/// Matches the TemplateStep2Screen design from the .pen file.
class AmountRow extends StatelessWidget {
  final String amount;
  final bool isSelected;
  final VoidCallback onTap;

  const AmountRow({
    super.key,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.98,
        duration: AppSpacing.durationFast,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppSpacing.durationFast,
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _RadioButton(isSelected: isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioButton extends StatelessWidget {
  static const _size = 22.0;
  static const _dotSize = 10.0;

  final bool isSelected;

  const _RadioButton({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppSpacing.durationFast,
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFF8E8E93),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.0,
          duration: AppSpacing.durationFast,
          curve: Curves.easeOutBack,
          child: Container(
            width: _dotSize,
            height: _dotSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundDark,
            ),
          ),
        ),
      ),
    );
  }
}
