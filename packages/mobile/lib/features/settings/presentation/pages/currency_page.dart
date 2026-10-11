import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_search_bar.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../helpers/currency_search.dart';
import '../widgets/settings_icon_tile.dart';
import '../widgets/settings_state_view.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton; `create` would close it on pop.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: CurrencyView()),
    );
  }
}

/// Picks the default currency. Amounts are not converted (ADR 0002).
class CurrencyView extends StatefulWidget {
  const CurrencyView({super.key});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  final _searchCtrl = TextEditingController();
  var _query = '';

  void _onQueryChanged(String query) => setState(() => _query = query);

  void _onCurrencyTap(String code) {
    context.read<SettingsBloc>().add(UpdateCurrency(code));
    context.pop();
  }

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final palette = context.palette;
    final currencies = searchCurrencies(_query);

    return Column(
      children: [
        Padding(
          padding: AppSpacing.pagePadding,
          child: AppSearchBar(
            controller: _searchCtrl,
            onChanged: _onQueryChanged,
            hintText: t.settings.currencyScreen.searchHint,
          ),
        ),
        const SizedBox(height: AppSpacing.smd),
        Expanded(
          child: currencies.isEmpty
              ? _buildNoResults(context)
              : Padding(
                  padding: AppSpacing.pagePadding,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    child: ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: currencies.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: palette.divider),
                      itemBuilder: (_, index) {
                        final currency = currencies[index];

                        return _CurrencyRow(
                          currency: currency,
                          selected: currency.code == settings.currencyCode,
                          onTap: () => _onCurrencyTap(currency.code),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          t.settings.currencyScreen.noResults(query: _query.trim()),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.currency,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final CurrencyInfo currency;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyRow({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: palette.surface,
      child: ListTile(
        onTap: onTap,
        selected: selected,
        leading: SettingsIconTile(
          selected: selected,
          idleForeground: palette.textPrimary,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: FittedBox(child: Text(currency.symbol.trim())),
          ),
        ),
        title: Text(
          currency.code,
          style: textTheme.bodyLarge?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          currency.displayName,
          style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        trailing: selected
            ? Icon(PiconsRegular.checkCircle, color: palette.brand)
            : null,
      ),
    );
  }
}
