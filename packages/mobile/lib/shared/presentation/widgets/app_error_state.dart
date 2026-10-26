import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.warningCircle, size: 48, color: colors.error),
            const SizedBox(height: AppSpacing.smd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: onRetry, child: Text(t.common.tryAgain)),
          ],
        ),
      ),
    );
  }
}
