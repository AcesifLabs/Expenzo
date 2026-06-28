import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A minimal, self-contained error screen for framework/build errors.
///
/// Shows "Unexpected error occurred" briefly, then closes the app.
/// The user can also tap anywhere to close immediately.
///
/// **Hard invariant:** this widget never renders the exception or stack
/// trace to the user. Full details go to the console only.
///
/// Unlike [AppErrorFallback], this widget has no retry, no feedback,
/// and no debug expander — it exists solely to surface a friendly
/// message before the app exits.
class AppCriticalError extends StatefulWidget {
  /// The error details captured by [ErrorWidget.builder].
  final FlutterErrorDetails details;

  const AppCriticalError({super.key, required this.details});

  @override
  State<AppCriticalError> createState() => _AppCriticalErrorState();
}

class _AppCriticalErrorState extends State<AppCriticalError> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Log full error details to console — never to the UI.
    debugPrint(
      'AppCriticalError: ${widget.details.exception}\n'
      '${widget.details.stack}',
    );
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) SystemNavigator.pop();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: scheme.error, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    'Unexpected error occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The app will close shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
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
