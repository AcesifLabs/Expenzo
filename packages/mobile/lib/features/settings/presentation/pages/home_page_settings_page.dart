import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
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

class HomePageSettingsPage extends StatelessWidget {
  const HomePageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton; `create` would close it on pop.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: HomePageSettingsView()),
    );
  }
}

/// The tab the app opens on at cold start. The design's "Scan SMS" option
/// is gone: Scan is not a tab (docs/adr/0006).
class HomePageSettingsView extends StatelessWidget {
  const HomePageSettingsView({super.key});

  /// The option's labels; also the Settings row subtitle.
  static ({String title, String subtitle}) optionFor(AppRootTab tab) {
    final options = t.settings.homePage.options;

    return switch (tab) {
      AppRootTab.home => (
        title: options.home.title,
        subtitle: options.home.subtitle,
      ),
      AppRootTab.activity => (
        title: options.activity.title,
        subtitle: options.activity.subtitle,
      ),
      AppRootTab.budgets => (
        title: options.budgets.title,
        subtitle: options.budgets.subtitle,
      ),
      AppRootTab.reports => (
        title: options.reports.title,
        subtitle: options.reports.subtitle,
      ),
    };
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final homePageT = t.settings.homePage;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            homePageT.intro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
        SettingsSection(
          title: homePageT.sections.defaultHomePage,
          children: [
            for (final tab in AppRootTab.values)
              if (optionFor(tab) case (:final title, :final subtitle))
                SettingsChoiceTile(
                  icon: tab.icon,
                  title: title,
                  subtitle: subtitle,
                  selected: tab == settings.homeTab,
                  onTap: () => _onTabTap(context, tab),
                ),
          ],
        ),
      ],
    );
  }

  void _onTabTap(BuildContext context, AppRootTab tab) {
    context.read<SettingsBloc>().add(UpdateHomeTab(tab));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.homePage.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
