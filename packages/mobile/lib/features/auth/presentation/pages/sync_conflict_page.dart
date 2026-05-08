import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

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
  void dispose() {
    try {
      di.getIt<SyncEngine>().onProgress = null;
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_syncing)
                  _buildProgressView()
                else
                  _buildDecisionView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionView() {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(Icons.sync, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        Text('Sync Conflict', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        Text('You have data on this device and in the cloud.\nHow would you like to proceed?',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryLight)),
        const SizedBox(height: 32),
        _decisionButton('Merge My Data', 'Keep all data from both sources', AppColors.primary, () => _executeDecision(SyncMode.merge)),
        const SizedBox(height: 12),
        _decisionButton('Replace with Cloud Data', 'Delete local data, use cloud version', colors.error, () => _showReplaceConfirm()),
        const SizedBox(height: 12),
        _decisionButton('Overwrite Cloud with Local', 'Replace cloud data with this device', Colors.orange, () => _executeDecision(SyncMode.localWins)),
      ],
    );
  }

  Widget _decisionButton(String title, String subtitle, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withAlpha(25),
          foregroundColor: color,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withAlpha(50))),
          elevation: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: color.withAlpha(180))),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _PieChartPainter(_progress),
            child: Center(
              child: Text('${(_progress * 100).toInt()}%', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(_status, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryLight)),
      ],
    );
  }

  void _showReplaceConfirm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace Local Data?'),
        content: const Text('This will permanently delete all data on this device and replace it with your cloud data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(ctx); _executeDecision(SyncMode.cloudWins); }, child: const Text('Replace', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> _executeDecision(SyncMode mode) async {
    setState(() { _syncing = true; _progress = 0; _status = 'Preparing...'; });

    try {
      final engine = di.getIt<SyncEngine>();
      engine.onProgress = (p) {
        if (mounted) setState(() { _progress = p; _status = 'Syncing...'; });
      };

      if (mode == SyncMode.cloudWins) {
        setState(() => _status = 'Resetting database...');
        await di.resetDatabaseInstance();
      }

      await engine.executeDecision(mode);

      if (mounted) {
        setState(() { _progress = 1.0; _status = 'Complete!'; });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.read<AuthBloc>().add(const AuthCheckRequested());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _syncing = false; _status = 'Error: ${e.toString().substring(0, min(50, e.toString().length))}'; });
      }
    }
  }
}

class _PieChartPainter extends CustomPainter {
  final double progress;
  _PieChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()..color = AppColors.primary.withAlpha(30)..style = PaintingStyle.stroke..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => old.progress != progress;
}
