import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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
  final VoidCallback onRetry;
  final VoidCallback onRestart;

  final VoidCallback? onResetLocalData;

  final VoidCallback onSendFeedback;

  const AppErrorFallback({
    super.key,
    required this.fallbackContext,
    required this.referenceId,
    this.exception,
    this.stack,
    this.formatDebugType,
    required this.onRetry,
    required this.onRestart,
    this.onResetLocalData,
    required this.onSendFeedback,
  });

  String get _title {
    final fallback = t.common.fallback;

    return switch (fallbackContext) {
      AppFallbackContext.init => fallback.initTitle,
      AppFallbackContext.build => fallback.errorTitle,
      AppFallbackContext.framework => fallback.errorTitle,
      AppFallbackContext.async => fallback.errorTitle,
    };
  }

  String get _body {
    final fallback = t.common.fallback;

    if (onResetLocalData != null) return fallback.storageBody;

    return switch (fallbackContext) {
      AppFallbackContext.init => fallback.initBody,
      _ => fallback.errorBody,
    };
  }

  Widget _errorIcon(ColorScheme scheme) {
    return Icon(PiconsRegular.warningCircle, color: scheme.error, size: 64);
  }

  Widget _errorTitle(ColorScheme scheme) {
    return Text(
      _title,
      textAlign: TextAlign.center,
      style: AppTypography.headlineSmall.copyWith(color: scheme.onSurface),
    );
  }

  Widget _errorBody(ColorScheme scheme) {
    return Text(
      _body,
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium.copyWith(
        height: 1.5,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _referenceLabel(ColorScheme scheme) {
    return SelectableText(
      t.common.fallback.reference(id: referenceId),
      textAlign: TextAlign.center,
      style: AppTypography.bodySmall.copyWith(
        letterSpacing: 0.5,
        color: scheme.onSurfaceVariant,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _retryButton() {
    return _FallbackButton(
      label: t.common.tryAgain,
      icon: PiconsRegular.arrowsClockwise,
      filled: true,
      onTap: onRetry,
    );
  }

  List<Widget> _buildActions(VoidCallback onSendFeedback) {
    final resetLocalData = onResetLocalData;

    return [
      _retryButton(),
      if (resetLocalData != null) ...[
        const SizedBox(height: AppSpacing.sm),
        _ResetLocalDataButton(onConfirmed: resetLocalData),
      ],
      const SizedBox(height: AppSpacing.sm),
      _FallbackButton(
        label: t.common.fallback.closeApp,
        icon: PiconsRegular.power,
        filled: false,
        onTap: onRestart,
      ),
      const SizedBox(height: AppSpacing.sm),
      _FallbackButton(
        label: t.common.sendFeedback,
        icon: PiconsRegular.chatCircleText,
        filled: false,
        textOnly: true,
        onTap: onSendFeedback,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localException = exception;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _errorIcon(scheme),
                    const SizedBox(height: AppSpacing.lg),
                    _errorTitle(scheme),
                    const SizedBox(height: AppSpacing.smd),
                    _errorBody(scheme),
                    const SizedBox(height: AppSpacing.smd),
                    _referenceLabel(scheme),
                    if (kDebugMode && localException != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _DebugDetails(
                        exception: localException,
                        formatDebugType: formatDebugType,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
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

class _ResetLocalDataButton extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _ResetLocalDataButton({required this.onConfirmed});

  @override
  State<_ResetLocalDataButton> createState() => _ResetLocalDataButtonState();
}

class _ResetLocalDataButtonState extends State<_ResetLocalDataButton> {
  bool _confirming = false;

  void _ask() => setState(() => _confirming = true);

  @override
  Widget build(BuildContext context) {
    final fallback = t.common.fallback;
    if (!_confirming) {
      return _FallbackButton(
        label: fallback.resetLocalData,
        icon: PiconsRegular.trash,
        filled: false,
        onTap: _ask,
      );
    }
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          fallback.resetConfirm,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: scheme.error),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FallbackButton(
          label: fallback.resetConfirmAction,
          icon: PiconsRegular.trash,
          filled: true,
          onTap: widget.onConfirmed,
        ),
      ],
    );
  }
}

class _FallbackButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool textOnly;
  final VoidCallback onTap;

  const _FallbackButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.textOnly = false,
    required this.onTap,
  });

  (Color, Color, BorderSide?) _resolveStyle(ColorScheme scheme) {
    if (textOnly) {
      return (Colors.transparent, scheme.primary, null);
    } else if (filled) {
      return (scheme.primary, scheme.onPrimary, null);
    } else {
      return (
        Colors.transparent,
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(color: fg),
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
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _expanded ? PiconsRegular.caretUp : PiconsRegular.caretDown,
              size: 18,
              color: mutedColor,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              t.common.fallback.debugDetails,
              style: AppTypography.bodySmall.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailContent(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: scheme.onSurface.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Text(
        _format(widget.exception),
        style: AppTypography.bodySmall.copyWith(
          fontFamily: 'monospace',
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
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          _detailContent(scheme),
        ],
      ],
    );
  }
}
