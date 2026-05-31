import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Feedback',
      child: const Center(child: Text('Coming soon')),
    );
  }
}