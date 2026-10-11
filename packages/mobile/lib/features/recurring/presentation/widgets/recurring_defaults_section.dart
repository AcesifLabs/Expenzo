import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_state_view.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../application/recurring_auto_poster.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/helpers/default_frequency.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';

/// DEFAULT FREQUENCY and AUTO-CREATE on the Recurring screen. Expects a
/// [SettingsBloc] and a [RecurringBloc] above it.
class RecurringDefaultsSection extends StatelessWidget {
  const RecurringDefaultsSection({super.key});

  static String _detailFor(RecurringFrequency frequency) {
    final defaultsT = t.recurring.defaults;

    return switch (frequency) {
      RecurringFrequency.weekly => defaultsT.weeklyDetail,
      RecurringFrequency.yearly => defaultsT.yearlyDetail,
      _ => defaultsT.monthlyDetail,
    };
  }

  static Future<bool> _isReadyToPost() async {
    if (!di.getIt.isRegistered<RecurringAutoPoster>()) return false;

    return di.getIt<RecurringAutoPoster>().isReadyToPost();
  }

  void _onFrequencyTap(BuildContext context, RecurringFrequency frequency) {
    context.read<SettingsBloc>().add(
      UpdateDefaultRecurringFrequency(frequency.name),
    );
  }

  /// Turning it on also posts what is already due, instead of waiting for
  /// the next app open. Before this session's first pull a signed-in device
  /// waits: the after-sync hook posts once the dates are fresh.
  Future<void> _onAutoCreateChanged(BuildContext context, bool enabled) async {
    context.read<SettingsBloc>().add(UpdateRecurringAutoCreate(enabled));
    if (!enabled) return;
    final recurringBloc = context.read<RecurringBloc>();
    if (!await _isReadyToPost()) return;
    recurringBloc.add(const ProcessRecurring(automatic: true));
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final sectionsT = t.recurring.sections;
    final defaultsT = t.recurring.defaults;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final selected = defaultFrequencyFrom(settings.defaultRecurringFrequency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSection(
          title: sectionsT.defaultFrequency,
          children: [
            for (final frequency in kDefaultFrequencyChoices)
              SettingsChoiceTile(
                title: frequency.displayName,
                subtitle: _detailFor(frequency),
                selected: frequency == selected,
                onTap: () => _onFrequencyTap(context, frequency),
              ),
          ],
        ),
        SettingsSection(
          title: sectionsT.autoCreate,
          children: [
            SwitchListTile(
              secondary: Icon(PiconsRegular.lightning, color: palette.accent),
              title: Text(defaultsT.autoCreate, style: textTheme.bodyMedium),
              subtitle: Text(
                defaultsT.autoCreateDetail,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              value: settings.recurringAutoCreate,
              onChanged: (enabled) => _onAutoCreateChanged(context, enabled),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsStateView(builder: _buildBody);
  }
}
