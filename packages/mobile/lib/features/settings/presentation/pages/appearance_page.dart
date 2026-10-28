import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/settings_choice_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';
import '../widgets/theme_preview_card.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: AppearanceView()),
    );
  }
}

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  static List<(String, String, IconData)> get options {
    final themeT = t.enums.theme;

    return [
      ('light', themeT.light, PiconsRegular.sun),
      ('dark', themeT.dark, PiconsRegular.moon),
      ('system', themeT.system, PiconsRegular.deviceMobile),
    ];
  }

  static String labelFor(String theme) {
    for (final (value, label, _) in options) {
      if (value == theme) return label;
    }

    return t.enums.theme.system;
  }

  static Brightness _brightnessFor(BuildContext context, String theme) {
    return switch (theme) {
      'light' => Brightness.light,
      'dark' => Brightness.dark,
      _ => MediaQuery.platformBrightnessOf(context),
    };
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final sectionsT = t.settings.appearanceScreen.sections;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        SettingsSection(
          title: sectionsT.theme,
          children: [
            for (final (value, label, icon) in options)
              SettingsChoiceTile(
                title: label,
                icon: icon,
                selected: settings.theme == value,
                onTap: () => _onThemeTap(context, value),
              ),
          ],
        ),
        SettingsSection(
          title: sectionsT.preview,
          children: [
            ThemePreviewCard(
              brightness: _brightnessFor(context, settings.theme),
            ),
          ],
        ),
      ],
    );
  }

  void _onThemeTap(BuildContext context, String theme) {
    context.read<SettingsBloc>().add(UpdateTheme(theme));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.appearance,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
