import 'package:flutter/material.dart';

class CurrencySelector extends StatefulWidget {
  final String currentSymbol;
  final ValueChanged<String> onSymbolSelected;

  const CurrencySelector({
    super.key,
    required this.currentSymbol,
    required this.onSymbolSelected,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  static const List<String> presetCurrencies = [
    '\$',
    '€',
    '£',
    '¥',
    '₹',
    '₽',
    '₩',
    '₿',
    'R\$',
    'A\$',
    'C\$',
    'CHF',
    'kr',
    'zł',
    '₺',
    '₫',
    'R',
    'RM',
    '₱',
    '฿',
  ];

  late TextEditingController _customController;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.currentSymbol);
    _isCustom = !presetCurrencies.contains(widget.currentSymbol);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetCurrencies.map((symbol) {
            final isSelected = widget.currentSymbol == symbol && !_isCustom;
            return ChoiceChip(
              label: Text(symbol),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _isCustom = false);
                  widget.onSymbolSelected(symbol);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _isCustom,
              onChanged: (value) {
                setState(() => _isCustom = value ?? false);
                if (_isCustom) {
                  widget.onSymbolSelected(_customController.text);
                } else {
                  widget.onSymbolSelected('\$_');
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _customController,
                enabled: _isCustom,
                decoration: InputDecoration(
                  labelText: 'Custom currency symbol',
                  hintText: 'Enter custom symbol',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isCustom
                      ? IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            widget.onSymbolSelected(_customController.text);
                          },
                        )
                      : null,
                ),
                onSubmitted: _isCustom ? widget.onSymbolSelected : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
