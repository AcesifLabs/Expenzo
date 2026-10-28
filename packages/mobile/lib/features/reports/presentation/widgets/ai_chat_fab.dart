import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AIChatFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AIChatFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'reports-ask-ai',
      onPressed: onPressed,
      tooltip: t.reports.askAi,
      shape: const CircleBorder(),
      child: const Icon(PiconsRegular.robot),
    );
  }
}
