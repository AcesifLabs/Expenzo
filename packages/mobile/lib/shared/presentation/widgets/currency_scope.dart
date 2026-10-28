import 'package:flutter/widgets.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class CurrencyScope extends StatefulWidget {
  final Widget child;

  const CurrencyScope({super.key, required this.child});

  @override
  State<CurrencyScope> createState() => _CurrencyScopeState();
}

class _CurrencyScopeState extends State<CurrencyScope> {
  @override
  void initState() {
    super.initState();
    CurrencyFormatter.current.addListener(_rebuildDescendants);
    CurrencyFormatter.displayFormat.addListener(_rebuildDescendants);
  }

  void _rebuildDescendants() {
    void markDirty(Element element) {
      element
        ..markNeedsBuild()
        ..visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  void dispose() {
    CurrencyFormatter.current.removeListener(_rebuildDescendants);
    CurrencyFormatter.displayFormat.removeListener(_rebuildDescendants);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
