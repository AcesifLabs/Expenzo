import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

enum AppFallbackContext { build, framework, async, init }

class AppErrorFallback extends StatelessWidget {
  final AppFallbackContext fallbackContext;

  final String referenceId;

  final Object? exception;

  final StackTrace? stack;

  final String Function(Object exception)? formatDebugType;

  final VoidCallback? onRetry;

  final VoidCallback? onHardReset;

  final VoidCallback? onRestart;

  final WidgetBuilder? feedbackBuilder;

  const AppErrorFallback({
    super.key,
    required this.fallbackContext,
    required this.referenceId,
    this.exception,
    this.stack,
    this.formatDebugType,
    this.onRetry,
    this.onHardReset,
    this.onRestart,
    this.feedbackBuilder,
  });

  static String generateReferenceId() {
    final raw = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final tail = raw.length <= 6 ? raw : raw.substring(raw.length - 6);
    return tail.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSendFeedback = _buildSendFeedbackHandler(context);

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: scheme.error, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: scheme.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      'Ref: $referenceId',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: scheme.onSurface.withAlpha(100),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (kDebugMode && exception != null) ...[
                      const SizedBox(height: 16),
                      _DebugDetails(
                        exception: exception!,
                        formatDebugType: formatDebugType,
                      ),
                    ],
                    const SizedBox(height: 32),
                    _FallbackButton(
                      label: 'Try Again',
                      icon: Icons.refresh,
                      filled: true,
                      onTap: onRetry,
                      onLongPress: onHardReset,
                    ),
                    if (onRestart != null) ...[
                      const SizedBox(height: 8),
                      _FallbackButton(
                        label: 'Close App',
                        icon: Icons.power_settings_new,
                        filled: false,
                        onTap: onRestart,
                      ),
                    ],
                    if (onSendFeedback != null) ...[
                      const SizedBox(height: 8),
                      _FallbackButton(
                        label: 'Send Feedback',
                        icon: Icons.feedback_outlined,
                        filled: false,
                        textOnly: true,
                        onTap: onSendFeedback,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _buildSendFeedbackHandler(BuildContext context) {
    final builder = feedbackBuilder;
    if (builder == null) return null;
    return () {
      Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: builder));
    };
  }

  String get _title {
    return switch (fallbackContext) {
      AppFallbackContext.init => 'App could not start',
      AppFallbackContext.build => 'Something went wrong',
      AppFallbackContext.framework => 'Something went wrong',
      AppFallbackContext.async => 'Something went wrong',
    };
  }

  String get _body {
    return switch (fallbackContext) {
      AppFallbackContext.init =>
        'We could not finish setting up the app. '
            'This is usually temporary — please try again, or restart the app.',
      _ =>
        'We hit an unexpected error. '
            'You can try again, restart the app, or send us feedback '
            'so we can fix it.',
    };
  }
}

class _FallbackButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool textOnly;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _FallbackButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.textOnly = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Color bg;
    final Color fg;
    final BorderSide? border;
    if (textOnly) {
      bg = Colors.transparent;
      fg = scheme.primary;
      border = null;
    } else if (filled) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
      border = null;
    } else {
      bg = Colors.transparent;
      fg = scheme.primary;
      border = BorderSide(color: scheme.primary, width: 1);
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bg,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
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

class _DebugDetails extends StatefulWidget {
  final Object exception;
  final String Function(Object exception)? formatDebugType;

  const _DebugDetails({required this.exception, this.formatDebugType});

  @override
  State<_DebugDetails> createState() => _DebugDetailsState();
}

class _DebugDetailsState extends State<_DebugDetails> {
  bool _expanded = false;

  String _format(Object exception) {
    final fn = widget.formatDebugType;
    return fn != null ? fn(exception) : exception.runtimeType.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: scheme.onSurface.withAlpha(120),
                ),
                const SizedBox(width: 4),
                Text(
                  'Details (debug)',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.onSurface.withAlpha(10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _format(widget.exception),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: scheme.onSurface.withAlpha(150),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
