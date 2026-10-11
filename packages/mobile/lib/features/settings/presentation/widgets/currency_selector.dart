import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';

/// Lists [CurrencyConfig.supported] by name; reports the picked ISO code.
class CurrencySelector extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onCurrencySelected;

  const CurrencySelector({
    super.key,
    required this.currentCode,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: CurrencyConfig.supported.length,
        itemBuilder: (context, index) {
          final currency = CurrencyConfig.supported[index];
          final isSelected = currency.code == currentCode;

          return ListTile(
            selected: isSelected,
            title: Text(currency.displayName),
            subtitle: Text('${currency.code} · ${currency.symbol.trim()}'),
            trailing: isSelected
                ? Icon(PiconsRegular.check, color: colors.primary)
                : null,
            onTap: () => onCurrencySelected(currency.code),
          );
        },
      ),
    );
  }
}
