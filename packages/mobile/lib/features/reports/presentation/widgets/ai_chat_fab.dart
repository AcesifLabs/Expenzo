import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Opens the AI assistant from Reports. Labelled, so it reads as "ask about
/// these numbers" rather than a second add button.
class AIChatFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AIChatFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      // The app shell has its own add button on the same screen.
      heroTag: 'reports-ask-ai',
      onPressed: onPressed,
      icon: const Icon(PiconsRegular.robot),
      label: Text(t.reports.askAi),
    );
  }
}
