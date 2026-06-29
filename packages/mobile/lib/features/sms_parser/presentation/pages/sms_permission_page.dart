import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import '../bloc/sms_permission_bloc.dart';
import '../bloc/sms_permission_event.dart';
import '../bloc/sms_permission_state.dart';

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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Continue'),
      ),
    );
  }

  Widget _buildPermanentlyDeniedSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(PiconsRegular.warning, color: AppColors.warning),
              const SizedBox(height: 8),
              const Text(
                'SMS permission was permanently denied. Please enable it in app settings.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildOpenSettingsButton(context),
      ],
    );
  }

  Widget _buildOpenSettingsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _onOpenSettings(context),
        child: const Text('Open Settings'),
      ),
    );
  }

  Widget _buildTimeoutSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(PiconsRegular.warningCircle, color: AppColors.error),
              const SizedBox(height: 8),
              const Text(
                'Permission request timed out. Please try again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildRetryButton(context),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoCard(
          icon: PiconsRegular.lock,
          title: 'Your Privacy Protected',
          description:
              'All SMS data is processed locally on your device. We never upload your messages to any server.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: PiconsRegular.database,
          title: 'Local Storage Only',
          description:
              'Detected expenses are stored locally. No personal messages are saved.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: PiconsRegular.slidersHorizontal,
          title: 'You\'re in Control',
          description:
              'Choose which SMS to convert to expenses. You can always edit or delete them.',
        ),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onRequestPermission(context),
        child: const Text('Try Again'),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, SmsPermissionState state) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(PiconsRegular.chat, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Enable SMS Scanning',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We scan your SMS to automatically detect expenses from banks and payment apps.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(),
              if (state is SmsPermissionLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildContinueButton(context),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: onSkip,
                    child: const Text('Not now'),
                  ),
                ),
              ],
              if (state is SmsPermissionPermanentlyDenied) ...[
                _buildPermanentlyDeniedSection(context),
              ],
              if (state is SmsPermissionTimeout) ...[
                _buildTimeoutSection(context),
              ],
              const SizedBox(height: 24),
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
