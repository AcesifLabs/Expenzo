import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';

class SyncConflictPage extends StatefulWidget {
  const SyncConflictPage({super.key});

  @override
  State<SyncConflictPage> createState() => _SyncConflictPageState();
}

class _SyncConflictPageState extends State<SyncConflictPage> {
  bool _syncing = false;
  double _progress = 0;
  String _status = '';

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDecisionView() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final palette = context.palette;
    final strings = t.auth.syncConflict;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(PiconsRegular.arrowsClockwise, size: 64, color: palette.brand),
        const SizedBox(height: AppSpacing.md),
        Text(
          strings.title,
          style: AppTypography.headlineLarge.copyWith(color: palette.brand),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings.body,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        _decisionButton(
          strings.merge,
          strings.mergeDetail,
          palette.brand,
          _onMergePressed,
        ),
        const SizedBox(height: AppSpacing.smd),
        _decisionButton(
          strings.useAccount,
          strings.useAccountDetail,
          colors.error,
          _onReplacePressed,
        ),
        const SizedBox(height: AppSpacing.smd),
        _decisionButton(
          strings.keepPhone,
          strings.keepPhoneDetail,
          colors.tertiary,
          _onOverwritePressed,
        ),
      ],
    );
  }

  Widget _decisionButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withAlpha(25),
          foregroundColor: color,
          padding: AppSpacing.paddingMd,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            side: BorderSide(color: color.withAlpha(50)),
          ),
          elevation: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _PieChartPainter(_progress, colors.primary),
              child: Center(
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style:
                      (theme.textTheme.headlineMedium ??
                              AppTypography.headlineLarge)
                          .copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _status,
            textAlign: TextAlign.center,
            style: (theme.textTheme.bodyLarge ?? AppTypography.bodyLarge)
                .copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showReplaceConfirm() {
    final strings = t.auth.syncConflict;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(strings.replaceTitle),
        content: Text(strings.replaceBody),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: _onConfirmReplace,
            child: Text(
              strings.replace,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirmReplace() {
    if (!mounted) return;
    Navigator.pop(context);
    _executeDecision(SyncMode.cloudWins);
  }

  void _onMergePressed() {
    _executeDecision(SyncMode.merge);
  }

  void _onReplacePressed() {
    _showReplaceConfirm();
  }

  void _onOverwritePressed() {
    _executeDecision(SyncMode.localWins);
  }

  Future<void> _executeDecision(SyncMode mode) async {
    setState(() {
      _syncing = true;
      _progress = 0;
      _status = t.auth.syncConflict.preparing;
    });

    try {
      final engine = di.getIt<SyncEngine>();
      engine.onProgress = _onProgress;
      if (mode == SyncMode.cloudWins) {
        // This device may hold the only copy of budget names the server lost
        // (ADR 0012); send them before the local data is wiped. A failure
        // stops the replace so the names are not lost.
        if (!await _saveLocalOnlyData()) return;
        setState(() => _status = t.auth.syncConflict.clearing);
        await di.resetDatabaseInstance();
      }
      await engine.executeDecision(mode);
      // The kept-alive tabs still show the replaced data.
      if (mode == SyncMode.cloudWins) di.getIt<LocalDataEpoch>().bump();

      if (!mounted) return;
      setState(() {
        _progress = 1.0;
        _status = t.auth.syncConflict.done;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      if (mounted) {
        setState(() {
          _syncing = false;
          _status = t.common.errors.generic;
        });
      }
    }
  }

  Future<bool> _saveLocalOnlyData() async {
    try {
      await di.getIt<SyncEngine>().prepareForLocalWipe();

      return true;
    } catch (e) {
      debugPrint(
        'SyncConflictPage: Local data upload failed: ${e.runtimeType}',
      );
      if (mounted) {
        setState(() => _syncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.auth.syncConflict.namesUploadFailed)),
        );
      }

      return false;
    }
  }

  void _onProgress(double p) {
    if (mounted) {
      setState(() {
        _progress = p;
        _status = t.auth.syncConflict.syncing;
      });
    }
  }

  @override
  void dispose() {
    try {
      di.getIt<SyncEngine>().onProgress = null;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SyncConflictPage: Failed to clear onProgress callback: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_syncing) _buildProgressView() else _buildDecisionView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  _PieChartPainter(this.progress, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = primaryColor.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) =>
      old.progress != progress || old.primaryColor != primaryColor;
}
