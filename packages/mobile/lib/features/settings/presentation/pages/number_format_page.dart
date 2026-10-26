import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/money_format.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/number_format_preview_card.dart';
import '../widgets/settings_choice_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';

class NumberFormatPage extends StatelessWidget {
  const NumberFormatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: NumberFormatView()),
    );
  }
}

class NumberFormatView extends StatelessWidget {
  static const previewAmount = 1234.56;
  static const _groupingSample = 123456789.0;

  const NumberFormatView({super.key});

  static String _sample(
    double value,
    int decimalPlaces,
    DigitGrouping grouping,
  ) {
    return MoneyFormat.plain(
      decimalDigits: decimalPlaces,
      grouping: grouping,
    ).format(value);
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        SettingsSection(
          title: t.settings.numberFormat.sections.preview,
          children: const [NumberFormatPreviewCard(amount: previewAmount)],
        ),
        _buildDecimalSection(context, settings),
        _buildGroupingSection(context, settings),
      ],
    );
  }

  Widget _buildDecimalSection(BuildContext context, UserSettings settings) {
    final numberFormatT = t.settings.numberFormat;
    final currency = CurrencyConfig.byCode(settings.currencyCode);
    final grouping = settings.digitGrouping;

    return SettingsSection(
      title: numberFormatT.sections.decimalPlaces,
      children: [
        for (final places in NumberDisplayFormat.allowedDecimalPlaces)
          SettingsChoiceTile(
            title: numberFormatT.places.count(n: places),
            subtitle: places > currency.decimalDigits
                ? numberFormatT.places.noMinorUnits(currency: currency.code)
                : _sample(previewAmount, places, grouping),
            selected: settings.decimalPlaces == places,
            enabled: places <= currency.decimalDigits,
            onTap: () => _onDecimalPlacesTap(context, places),
          ),
      ],
    );
  }

  Widget _buildGroupingSection(BuildContext context, UserSettings settings) {
    return SettingsSection(
      title: t.settings.numberFormat.sections.grouping,
      children: [
        for (final grouping in DigitGrouping.values)
          SettingsChoiceTile(
            title: _sample(_groupingSample, 0, grouping),
            subtitle: grouping.displayName,
            selected: settings.digitGrouping == grouping,
            onTap: () => _onGroupingTap(context, grouping),
          ),
      ],
    );
  }

  void _onDecimalPlacesTap(BuildContext context, int decimalPlaces) {
    context.read<SettingsBloc>().add(
      UpdateNumberFormat(decimalPlaces: decimalPlaces),
    );
  }

  void _onGroupingTap(BuildContext context, DigitGrouping grouping) {
    context.read<SettingsBloc>().add(
      UpdateNumberFormat(digitGrouping: grouping),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.numberFormat.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
