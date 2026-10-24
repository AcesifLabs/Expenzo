import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';

import '../widgets/tutorial_pages.dart';

/// `/tutorial` (Help → Watch tutorial). Only the tutorial; settings are left
/// alone.
class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(),
            ),
            Expanded(child: TutorialPages(onDone: () => context.pop())),
          ],
        ),
      ),
    );
  }
}
