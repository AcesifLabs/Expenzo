import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmsPermissionBloc, SmsPermissionState>(
      listener: (context, state) {
        if (state is SmsPermissionGranted) {
          onPermissionGranted();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Icon(
                    PhosphorIcons.chat(PhosphorIconsStyle.regular),
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enable SMS Scanning',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We scan your SMS to automatically detect expenses from banks and payment apps.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    icon: PhosphorIcons.lock(PhosphorIconsStyle.regular),
                    title: 'Your Privacy Protected',
                    description:
                        'All SMS data is processed locally on your device. We never upload your messages to any server.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: PhosphorIcons.database(PhosphorIconsStyle.regular),
                    title: 'Local Storage Only',
                    description:
                        'Detected expenses are stored locally. No personal messages are saved.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: PhosphorIcons.slidersHorizontal(PhosphorIconsStyle.regular),
                    title: 'You\'re in Control',
                    description:
                        'Choose which SMS to convert to expenses. You can always edit or delete them.',
                  ),
                  const Spacer(),
                  if (state is SmsPermissionLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SmsPermissionBloc>().add(
                            const RequestSmsPermission(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: onSkip,
                        child: const Text('Not now'),
                      ),
                    ),
                  ],
                  if (state is SmsPermissionPermanentlyDenied) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            PhosphorIcons.warning(PhosphorIconsStyle.regular),
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'SMS permission was permanently denied. Please enable it in app settings.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<SmsPermissionBloc>().add(
                            const OpenAppSettings(),
                          );
                        },
                        child: const Text('Open Settings'),
                      ),
                    ),
                  ],
                  if (state is SmsPermissionTimeout) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.regular), color: AppColors.error),
                          const SizedBox(height: 8),
                          const Text(
                            'Permission request timed out. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SmsPermissionBloc>().add(
                            const RequestSmsPermission(),
                          );
                        },
                        child: const Text('Try Again'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
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
}
