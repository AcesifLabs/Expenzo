import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../bloc/sms_permission_bloc.dart';
import '../bloc/sms_permission_event.dart';
import '../bloc/sms_permission_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SmsPermissionPage extends StatelessWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback onSkip;

  const SmsPermissionPage({
    super.key,
    required this.onPermissionGranted,
    required this.onSkip,
  });

  void _onStateChange(BuildContext _, SmsPermissionState state) {
    if (state is SmsPermissionGranted) {
      onPermissionGranted();
    }
  }

  void _onRequestPermission(BuildContext context) {
    context.read<SmsPermissionBloc>().add(const RequestSmsPermission());
  }

  void _onOpenSettings(BuildContext context) {
    context.read<SmsPermissionBloc>().add(const OpenAppSettings());
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.palette.accentFill.withAlpha(60),
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
          child: Icon(icon, color: context.palette.brand, size: 24),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onRequestPermission(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Text(t.smsParser.permission.next),
      ),
    );
  }

  Widget _buildPermanentlyDeniedSection(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.warning.withAlpha(51),
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
          child: Column(
            children: [
              Icon(PiconsRegular.warning, color: palette.warning),
              const SizedBox(height: AppSpacing.sm),
              Text(t.smsParser.permission.denied, textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.smd),
        _buildOpenSettingsButton(context),
      ],
    );
  }

  Widget _buildOpenSettingsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _onOpenSettings(context),
        child: Text(t.common.openSettings),
      ),
    );
  }

  Widget _buildTimeoutSection(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.error.withAlpha(51),
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
          child: Column(
            children: [
              Icon(PiconsRegular.warningCircle, color: palette.error),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.smsParser.permission.timedOut,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.smd),
        _buildRetryButton(context),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final strings = t.smsParser.permission;

    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: PiconsRegular.lock,
          title: strings.privacyTitle,
          description: strings.privacyBody,
        ),
        const SizedBox(height: AppSpacing.smd),
        _buildInfoCard(
          context,
          icon: PiconsRegular.database,
          title: strings.localTitle,
          description: strings.localBody,
        ),
        const SizedBox(height: AppSpacing.smd),
        _buildInfoCard(
          context,
          icon: PiconsRegular.slidersHorizontal,
          title: strings.controlTitle,
          description: strings.controlBody,
        ),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onRequestPermission(context),
        child: Text(t.common.tryAgain),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, SmsPermissionState state) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final strings = t.smsParser.permission;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(PiconsRegular.chat, size: 80, color: palette.brand),
              const SizedBox(height: AppSpacing.lg),
              Text(
                strings.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(strings.body, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              _buildInfoSection(context),
              if (state is SmsPermissionLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildContinueButton(context),
                const SizedBox(height: AppSpacing.smd),
                Center(
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(t.common.notNow),
                  ),
                ),
              ],
              if (state is SmsPermissionPermanentlyDenied) ...[
                _buildPermanentlyDeniedSection(context),
              ],
              if (state is SmsPermissionTimeout) ...[
                _buildTimeoutSection(context),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmsPermissionBloc, SmsPermissionState>(
      listener: _onStateChange,
      builder: (context, state) => _buildPageContent(context, state),
    );
  }
}
