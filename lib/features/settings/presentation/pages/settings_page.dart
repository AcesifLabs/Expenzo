import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/currency_selector.dart';
import 'delete_account_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Settings saved')));
            context.read<SettingsBloc>().add(const LoadSettings());
          }
          if (state is SettingsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsLoaded) {
            return _buildSettingsForm(context, state);
          }
          return const Center(child: Text('Loading settings...'));
        },
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, SettingsLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Currency'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CurrencySelector(
              currentSymbol: state.settings.currencySymbol,
              onSymbolSelected: (symbol) {
                context.read<SettingsBloc>().add(UpdateCurrencySymbol(symbol));
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Email Fetch Limit'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.settings.emailFetchLimit} emails',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: state.settings.emailFetchLimit.toDouble(),
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: state.settings.emailFetchLimit.toString(),
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateEmailFetchLimit(value.toInt()),
                    );
                  },
                ),
                Text(
                  'Maximum number of emails to fetch when scanning',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Notifications'),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts for budget warnings'),
            value: state.settings.notificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                UpdateNotificationsEnabled(value),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Appearance'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('System'),
                subtitle: const Text('Follow system theme'),
                value: 'system',
                groupValue: state.settings.theme,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateTheme(value));
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'light',
                groupValue: state.settings.theme,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateTheme(value));
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'dark',
                groupValue: state.settings.theme,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateTheme(value));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Danger Zone'),
        const SizedBox(height: 8),
        Card(
          color: AppColors.error.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(LucideIcons.trash2, color: AppColors.error),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text('This action cannot be undone'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteAccountDialog(
        onConfirm: () {
          context.read<SettingsBloc>().add(const DeleteAccountEvent());
        },
      ),
    );
  }
}
