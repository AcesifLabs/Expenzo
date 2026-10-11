import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton; `create` would close it on pop.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: LanguageView()),
    );
  }
}

/// Match device, English and বাংলা. Three options, so no search field.
class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  /// The app languages as (code, title). Language names are shown in their
  /// own script, never translated. Also read by the Settings row subtitle.
  static List<(String, String)> get options => [
    ('system', t.settings.language.matchDevice),
    ('en', 'English'),
    ('bn', 'বাংলা'),
  ];

  /// The title for [languageCode]; Match device for anything unknown.
  static String labelFor(String languageCode) {
    for (final (code, title) in options) {
      if (code == languageCode) return title;
    }

    return t.settings.language.matchDevice;
  }

  static String _subtitleFor(String code) {
    final languageT = t.settings.language;

    return switch (code) {
      'en' => languageT.names.en,
      'bn' => languageT.names.bn,
      _ => languageT.matchDeviceSubtitle,
    };
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        SettingsSection(
          title: t.settings.language.sections.appLanguage,
          children: [
            for (final (code, title) in options)
              SettingsChoiceTile(
                title: title,
                subtitle: _subtitleFor(code),
                selected: settings.languageCode == code,
                onTap: () => _onLanguageTap(context, code),
              ),
          ],
        ),
      ],
    );
  }

  void _onLanguageTap(BuildContext context, String code) {
    context.read<SettingsBloc>().add(UpdateLanguage(code));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.language.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
