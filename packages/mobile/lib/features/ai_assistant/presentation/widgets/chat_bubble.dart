import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:picons/picons.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  Widget _buildUserBubble(AppPalette palette) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(AppSpacing.smd),
        decoration: BoxDecoration(
          color: palette.brandFill,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusControl),
            topRight: Radius.circular(AppSpacing.radiusControl),
            bottomLeft: Radius.circular(AppSpacing.radiusControl),
            bottomRight: Radius.circular(AppSpacing.radiusPill),
          ),
        ),
        child: Text(
          message.content,
          style: AppTypography.bodyMedium.copyWith(color: palette.onBrandFill),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(AppPalette palette, String timeStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: palette.brandFill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
          child: Center(
            child: Icon(
              PiconsRegular.robot,
              size: 24,
              color: palette.onBrandFill,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.smd),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusControl),
                    topRight: Radius.circular(AppSpacing.radiusControl),
                    bottomLeft: Radius.circular(AppSpacing.radiusControl),
                    bottomRight: Radius.circular(AppSpacing.radiusPill),
                  ),
                ),
                child: MarkdownBody(
                  data: message.content,
                  selectable: false,
                  shrinkWrap: true,
                  softLineBreak: true,
                  styleSheet: _assistantMarkdownStyleSheet(palette),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                timeStr,
                style: AppTypography.bodySmall.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  MarkdownStyleSheet _assistantMarkdownStyleSheet(AppPalette palette) {
    return MarkdownStyleSheet(
      p: AppTypography.bodyMedium.copyWith(
        color: palette.textPrimary,
        height: 1.4,
      ),
      h1: AppTypography.titleLarge.copyWith(color: palette.textPrimary),
      h2: AppTypography.titleMedium.copyWith(color: palette.textPrimary),
      h3: AppTypography.labelLarge.copyWith(color: palette.textPrimary),
      strong: AppTypography.labelLarge.copyWith(color: palette.textPrimary),
      em: AppTypography.bodyMedium.copyWith(
        fontStyle: FontStyle.italic,
        color: palette.textPrimary,
      ),
      code: AppTypography.bodySmall.copyWith(
        fontFamily: 'monospace',
        color: palette.textPrimary,
      ),
      codeblockDecoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      blockquote: AppTypography.bodyMedium.copyWith(
        color: palette.textSecondary,
        height: 1.4,
      ),
      blockquotePadding: const EdgeInsets.all(AppSpacing.smd),
      blockquoteDecoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        border: Border.all(color: palette.textSecondary.withAlpha(0x40)),
      ),
      listBullet: AppTypography.bodyMedium.copyWith(color: palette.textPrimary),
      a: AppTypography.bodyMedium.copyWith(
        color: palette.brand,
        decoration: TextDecoration.underline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUser = message.role == ChatRole.user;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    if (isUser) {
      return _buildUserBubble(palette);
    }

    return _buildAssistantBubble(palette, timeStr);
  }
}
