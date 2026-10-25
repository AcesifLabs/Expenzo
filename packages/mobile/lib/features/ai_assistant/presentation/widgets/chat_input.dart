import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:flutter/services.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    required this.onSubmitted,
    required this.onSend,
  });

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  InputDecoration _decoration(AppPalette palette) {
    final defaultBorder = _border(palette.textSecondary.withAlpha(0x40));

    return InputDecoration(
      hintText: t.aiAssistant.inputHint,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: palette.textSecondary,
      ),
      filled: true,
      fillColor: palette.surface,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      border: defaultBorder,
      enabledBorder: defaultBorder,
      focusedBorder: _border(palette.brand),
      disabledBorder: _border(palette.inputStroke),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              // A 48 dp tap target that grows with large text.
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTapTarget,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLength: AiAssistantConstants.maxUserPromptLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                onSubmitted: onSubmitted,
                style: AppTypography.bodyMedium.copyWith(
                  color: palette.textPrimary,
                ),
                decoration: _decoration(palette),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            enabled: enabled,
            label: t.aiAssistant.send,
            child: GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled ? palette.brandFill : palette.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Center(
                  child: Icon(
                    PiconsRegular.paperPlaneRight,
                    size: 20,
                    color: enabled
                        ? palette.onBrandFill
                        : palette.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
