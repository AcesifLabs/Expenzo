import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/currency_selector.dart';
import 'delete_account_dialog.dart';
import '../../domain/entities/user_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
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
        final settings = state is SettingsLoaded ? state.settings : null;
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            // Profile card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: _ProfileHeader(),
              ),
            ),
            // Settings
            if (settings != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsBody(settings: settings),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is Authenticated
        ? (authState.user.displayName ?? 'User')
        : 'User';
    final email = authState is Authenticated ? authState.user.email : null;
    final photoUrl = authState is Authenticated
        ? authState.user.photoUrl
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withAlpha(25),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(140),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            PhosphorIcons.pencilSimple(PhosphorIconsStyle.light),
            color: Colors.white.withAlpha(120),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final UserSettings settings;
  const _SettingsBody({required this.settings});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _Section(title: 'Account'),
        const SizedBox(height: 8),
        _SettingTile(
          icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.light),
          title: 'Currency',
          trailing: Text(
            settings.currencySymbol,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withAlpha(160),
            ),
          ),
          onTap: () => _showCurrencyPicker(context),
        ),
        _Divider(),
        _SettingTile(
          icon: PhosphorIcons.bell(PhosphorIconsStyle.light),
          title: 'Notifications',
          trailing: Switch(
            value: settings.notificationsEnabled,
            activeColor: const Color(0xFF34C759),
            onChanged: (v) {
              context.read<SettingsBloc>().add(UpdateNotificationsEnabled(v));
            },
          ),
        ),
        _Divider(),
        _SettingTile(
          icon: PhosphorIcons.sun(PhosphorIconsStyle.light),
          title: 'Theme',
          trailing: Text(
            _themeLabel(settings.theme),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withAlpha(160),
            ),
          ),
          onTap: () => _showThemePicker(context),
        ),
        const SizedBox(height: 24),
        _Section(title: 'Preferences'),
        const SizedBox(height: 8),
        _SettingTile(
          icon: PhosphorIcons.envelope(PhosphorIconsStyle.light),
          title: 'Email Fetch Limit',
          subtitle: '${settings.emailFetchLimit} emails',
          trailing: Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.light),
            color: colors.onSurface.withAlpha(80),
            size: 20,
          ),
          onTap: () => _showEmailLimitPicker(context),
        ),
        const SizedBox(height: 24),
        _Section(title: 'Support'),
        const SizedBox(height: 8),
        _SettingTile(
          icon: PhosphorIcons.question(PhosphorIconsStyle.light),
          title: 'Help & FAQ',
          trailing: Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.light),
            color: colors.onSurface.withAlpha(80),
            size: 20,
          ),
        ),
        _Divider(),
        _SettingTile(
          icon: PhosphorIcons.info(PhosphorIconsStyle.light),
          title: 'About',
          trailing: Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.light),
            color: colors.onSurface.withAlpha(80),
            size: 20,
          ),
        ),
        const SizedBox(height: 32),
        _SettingTile(
          icon: PhosphorIcons.trash(PhosphorIconsStyle.light),
          title: 'Delete Account',
          titleColor: const Color(0xFFFF3B30),
          onTap: () => _showDeleteDialog(context),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  String _themeLabel(String t) {
    switch (t) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: CurrencySelector(
          currentSymbol: settings.currencySymbol,
          onSymbolSelected: (s) {
            context.read<SettingsBloc>().add(UpdateCurrencySymbol(s));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.light)),
                title: const Text('System'),
                trailing: settings.theme == 'system'
                    ? Icon(
                        PhosphorIcons.check(PhosphorIconsStyle.fill),
                        color: colors.primary,
                      )
                    : null,
                onTap: () {
                  context.read<SettingsBloc>().add(UpdateTheme('system'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.sun(PhosphorIconsStyle.light)),
                title: const Text('Light'),
                trailing: settings.theme == 'light'
                    ? Icon(
                        PhosphorIcons.check(PhosphorIconsStyle.fill),
                        color: colors.primary,
                      )
                    : null,
                onTap: () {
                  context.read<SettingsBloc>().add(UpdateTheme('light'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.moon(PhosphorIconsStyle.light)),
                title: const Text('Dark'),
                trailing: settings.theme == 'dark'
                    ? Icon(
                        PhosphorIcons.check(PhosphorIconsStyle.fill),
                        color: colors.primary,
                      )
                    : null,
                onTap: () {
                  context.read<SettingsBloc>().add(UpdateTheme('dark'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailLimitPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Fetch Limit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: settings.emailFetchLimit.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                label: settings.emailFetchLimit.toString(),
                onChanged: (v) {
                  context.read<SettingsBloc>().add(
                    UpdateEmailFetchLimit(v.toInt()),
                  );
                },
                onChangeEnd: (_) => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colors.onSurface.withAlpha(160), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? colors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
    );
  }
}
