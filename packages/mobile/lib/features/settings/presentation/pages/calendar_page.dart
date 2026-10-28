import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/calendar_month_preview.dart';
import '../widgets/settings_choice_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: CalendarView()),
    );
  }
}

class CalendarView extends StatelessWidget {
  final DateTime Function() clock;

  const CalendarView({super.key, this.clock = DateTime.now});

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final selected = settings.effectiveFirstDayOfWeek(
      LocaleSettings.currentLocale.languageCode,
    );

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        SettingsSection(
          title: t.settings.calendar.sections.firstDayOfWeek,
          children: [
            for (final day in FirstDayOfWeek.values)
              SettingsChoiceTile(
                title: day.displayName,
                selected: day == selected,
                onTap: () => _onDayTap(context, day),
              ),
          ],
        ),
        SettingsSection(
          title: null,
          children: [CalendarMonthPreview(day: selected, today: clock())],
        ),
      ],
    );
  }

  void _onDayTap(BuildContext context, FirstDayOfWeek day) {
    context.read<SettingsBloc>().add(UpdateFirstDayOfWeek(day));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.calendar.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
