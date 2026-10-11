import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Rebuilds everything below it when the app language changes.
///
/// Widgets read the global `t` (like the static `CurrencyFormatter`), which
/// they don't subscribe to, so a language change marks every element dirty
/// once. State (scroll, forms, navigation) is kept because nothing is
/// recreated. Same approach as `CurrencyScope`.
class LocaleScope extends StatefulWidget {
  final Widget child;

  const LocaleScope({super.key, required this.child});

  @override
  State<LocaleScope> createState() => _LocaleScopeState();
}

class _LocaleScopeState extends State<LocaleScope> {
  StreamSubscription<AppLocale>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = LocaleSettings.getLocaleStream().listen(
      (_) => _rebuildDescendants(),
    );
  }

  void _rebuildDescendants() {
    if (!mounted) return;
    void markDirty(Element element) {
      element
        ..markNeedsBuild()
        ..visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
