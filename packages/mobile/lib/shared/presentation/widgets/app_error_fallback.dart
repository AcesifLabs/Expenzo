import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppErrorFallback extends StatelessWidget {
  static String generateReferenceId() {
    final raw = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final tail = raw.length <= 6 ? raw : raw.substring(raw.length - 6);

    return tail.toUpperCase();
  }

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

  VoidCallback? _buildSendFeedbackHandler(BuildContext context) {
    final builder = feedbackBuilder;
    if (builder == null) return null;

    return () {
      context.push('/feedback');
    };
  }

  Widget _errorIcon(ColorScheme scheme) {
    return Icon(Icons.error_outline, color: scheme.error, size: 64);
  }

  Widget _errorTitle(ColorScheme scheme) {
    return Text(
      _title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
    );
  }

  Widget _errorBody(ColorScheme scheme) {
    return Text(
      _body,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: scheme.onSurface.withAlpha(140),
      ),
    );
  }

  Widget _referenceLabel(ColorScheme scheme) {
    return SelectableText(
      'Ref: $referenceId',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 0.5,
        color: scheme.onSurface.withAlpha(100),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _retryButton() {
    return _FallbackButton(
      label: 'Try Again',
      icon: Icons.refresh,
      filled: true,
      onTap: onRetry,
      onLongPress: onHardReset,
    );
  }

  List<Widget> _buildActions(VoidCallback? onSendFeedback) {
    return [
      _retryButton(),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSendFeedback = _buildSendFeedbackHandler(context);
    final localException = exception;

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
                    _errorIcon(scheme),
                    const SizedBox(height: 24),
                    _errorTitle(scheme),
                    const SizedBox(height: 12),
                    _errorBody(scheme),
                    const SizedBox(height: 12),
                    _referenceLabel(scheme),
                    if (kDebugMode && localException != null) ...[
                      const SizedBox(height: 16),
                      _DebugDetails(
                        exception: localException,
                        formatDebugType: formatDebugType,
                      ),
                    ],
                    const SizedBox(height: 32),
                    ..._buildActions(onSendFeedback),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppFallbackContext { build, framework, async, init }

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

  (Color, Color, BorderSide?) _resolveStyle(ColorScheme scheme) {
    if (textOnly) {
      return (const Color(0x00000000), scheme.primary, null);
    } else if (filled) {
      return (scheme.primary, scheme.onPrimary, null);
    } else {
      return (
        const Color(0x00000000),
        scheme.primary,
        BorderSide(color: scheme.primary, width: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, border) = _resolveStyle(scheme);

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

  Widget _expandToggle(Color mutedColor) {
    return InkWell(
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
              color: mutedColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Details (debug)',
              style: TextStyle(fontSize: 12, color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailContent(ColorScheme scheme) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedColor = scheme.onSurface.withAlpha(120);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _expandToggle(mutedColor),
        if (_expanded) ...[const SizedBox(height: 4), _detailContent(scheme)],
      ],
    );
  }
}
