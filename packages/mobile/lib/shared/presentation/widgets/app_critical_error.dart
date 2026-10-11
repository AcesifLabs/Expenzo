import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AppCriticalError extends StatefulWidget {
  final FlutterErrorDetails details;

  const AppCriticalError({super.key, required this.details});

  @override
  State<AppCriticalError> createState() => _AppCriticalErrorState();
}

class _AppCriticalErrorState extends State<AppCriticalError> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    debugPrint(
      'AppCriticalError: ${widget.details.exception}\n'
      '${widget.details.stack}',
    );

    _timer = Timer(const Duration(seconds: 3), _onTimerElapsed);
  }

  void _onTimerElapsed() {
    if (mounted) SystemNavigator.pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => SystemNavigator.pop(),
      child: Material(
        color: scheme.surface,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PiconsRegular.warningCircle,
                    color: scheme.error,
                    size: 64,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    t.common.fallback.criticalTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  Text(
                    t.common.fallback.criticalBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1.5,
                      color: scheme.onSurface.withAlpha(140),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
