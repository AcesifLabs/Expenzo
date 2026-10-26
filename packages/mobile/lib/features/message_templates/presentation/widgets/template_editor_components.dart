import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';

enum _StepDotState { completed, active, inactive }

class StepProgressIndicator extends StatelessWidget {
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

  Color _colorFor(_StepDotState state, AppPalette palette) {
    return switch (state) {
      _StepDotState.completed => palette.income,
      _StepDotState.active => palette.brand,
      _StepDotState.inactive => palette.textSecondary.withAlpha(0x40),
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 1; i <= totalSteps; i++) ...[
            _StepDot(color: _colorFor(_stateFor(i), palette)),
            if (i < totalSteps)
              _StepLine(
                color: _colorFor(
                  i < currentStep
                      ? _StepDotState.completed
                      : _StepDotState.inactive,
                  palette,
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        color: color,
      ),
    );
  }
}

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
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: AppTypography.labelMedium.copyWith(
              color: palette.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            messageBody,
            style: AppTypography.bodyMedium.copyWith(
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

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

  Widget _chip(AppPalette palette) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.98,
      duration: AppSpacing.durationFast,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: AppSpacing.durationFast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.brand.withAlpha(0x20)
              : palette.surfaceHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(
            color: isSelected ? palette.brand : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          word,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? palette.brand : palette.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Center(widthFactor: 1, child: _chip(palette)),
        ),
      ),
    );
  }
}

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
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.98,
          duration: AppSpacing.durationFast,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: AppSpacing.durationFast,
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
              border: Border.all(
                color: isSelected ? palette.brand : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _RadioButton(isSelected: isSelected),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    amount,
                    style: AppTypography.titleLarge.copyWith(
                      color: palette.brand,
                    ),
                  ),
                ),
              ],
            ),
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
    final palette = context.palette;

    return AnimatedContainer(
      duration: AppSpacing.durationFast,
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? palette.brand : Colors.transparent,
        border: Border.all(
          color: isSelected ? palette.brand : palette.textSecondary,
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.bg,
            ),
          ),
        ),
      ),
    );
  }
}
