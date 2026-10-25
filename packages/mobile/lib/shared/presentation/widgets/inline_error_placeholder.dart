import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

/// Stands in for one widget that threw while building (the app's
/// `ErrorWidget.builder`). The rest of the screen keeps working; the error
/// itself goes to `FlutterError.onError`.
///
/// It can be built anywhere, even above `MaterialApp`, so it brings its own
/// text direction and reads colors from the nearest theme or the default.
class InlineErrorPlaceholder extends StatelessWidget {
  final FlutterErrorDetails details;

  const InlineErrorPlaceholder({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = t.common.fallback.errorTitle;
    final content = Semantics(
      label: title,
      container: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PiconsRegular.warningCircle, color: scheme.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  // Release builds never show the exception text.
                  kDebugMode ? '$title: ${details.exceptionAsString()}' : title,
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: kDebugMode ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Directionality.maybeOf(context) == null
        ? Directionality(textDirection: TextDirection.ltr, child: content)
        : content;
  }
}
