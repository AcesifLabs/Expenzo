import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AIChatFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AIChatFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'reports-ask-ai',
      onPressed: onPressed,
      icon: const Icon(PiconsRegular.robot),
      label: Text(t.reports.askAi),
    );
  }
}
