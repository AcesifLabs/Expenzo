import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_search_bar.dart';

import '../../domain/faq_entry.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final _searchController = TextEditingController();
  var _query = '';

  void _onQueryChanged(String query) => setState(() => _query = query);

  Widget _entryCard(BuildContext context, FaqEntry entry, int index) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: palette.surface,
      borderRadius: AppSpacing.radiusCard,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey(entry.id),

        initiallyExpanded: index == 0 && _query.trim().isEmpty,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(entry.question, style: textTheme.bodyLarge),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(
            entry.answer,
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqT = t.support.faq;
    final query = _query.trim();

    final entries = filterFaqEntries(faqEntries(), query);

    return Scaffold(
      body: AppScaffold(
        title: faqT.title,
        leading: const AppBackButton(),
        child: ListView(
          padding: AppSpacing.pagePadding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            AppSearchBar(
              controller: _searchController,
              onChanged: _onQueryChanged,
              hintText: faqT.searchHint,
            ),
            const SizedBox(height: AppSpacing.md),
            if (entries.isEmpty)
              AppEmptyState(
                icon: PiconsRegular.magnifyingGlass,
                message: faqT.noResults(query: query),
              ),
            for (final (index, entry) in entries.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.sm),
              _entryCard(context, entry, index),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
