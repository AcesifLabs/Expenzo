import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../core/constants/record_type.dart';
import '../bloc/record_bloc.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';

class RecordFilterModal extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final String? recordType;

  final void Function({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    String? recordType,
  })
  onApply;

  final VoidCallback onClear;

  const RecordFilterModal({
    super.key,
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<RecordFilterModal> createState() => _RecordFilterModalState();
}

class _RecordFilterModalState extends State<RecordFilterModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedCategoryIds = {};
  RecordType? _recordType;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    final categoryIds = widget.categoryIds;
    if (categoryIds != null) {
      _selectedCategoryIds.addAll(categoryIds);
    }
    final recordTypeDb = widget.recordType;
    if (recordTypeDb != null) {
      _recordType = recordTypeDb == RecordType.income.dbValue
          ? RecordType.income
          : RecordType.expense;
    }

    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _pickDateRange() async {
    final startDate = _startDate;
    final endDate = _endDate;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: AppConstants.pickerFirstDate,
      lastDate: clock.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _handleApply() {
    widget.onApply(
      startDate: _startDate,
      endDate: _endDate,
      categoryIds: _selectedCategoryIds.isEmpty
          ? null
          : _selectedCategoryIds.toList(),
      recordType: _recordType?.dbValue,
    );
    Navigator.of(context).pop();
  }

  void _handleClear() {
    widget.onClear();
    Navigator.of(context).pop();
  }

  void _onTypeSelected(RecordType? type) {
    setState(() {
      _recordType = type;
      if (type == null) return;
      final state = context.read<CategoryBloc>().state;
      if (state is! CategoryLoaded) return;
      final otherTypeIds = state.categories
          .where((c) => c.type != type)
          .map((c) => c.id);
      _selectedCategoryIds.removeAll(otherTypeIds);
    });
  }

  List<Category> _visibleCategories(List<Category> categories) {
    final type = _recordType;
    if (type == null) return categories;

    return categories.where((c) => c.type == type).toList();
  }

  Color _chipLabelColor(ThemeData theme, bool selected) {
    if (!selected) return theme.colorScheme.onSurface;

    return theme.colorScheme.onPrimary;
  }

  String _categoryLabel(int selectedCount, int totalCount) {
    final strings = t.records.filter;
    if (selectedCount == 0) return strings.allCategories;
    if (selectedCount == totalCount) {
      return strings.allCount(n: selectedCount);
    }

    return strings.selectedCount(n: selectedCount);
  }

  String _formatDate(DateTime dt) {
    return MaterialLocalizations.of(context).formatMediumDate(dt);
  }

  void _onCategoryToggle(Category cat, bool? val, StateSetter setDialogState) {
    setDialogState(() {
      if (val == true) {
        final catId = cat.id;
        if (catId != null) _selectedCategoryIds.add(catId);
      } else {
        final catId = cat.id;
        if (catId != null) _selectedCategoryIds.remove(catId);
      }
    });
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    final sd = _startDate;
    final ed = _endDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.records.filter.dateRange, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _DateRangeBox(
          startDate: sd,
          endDate: ed,
          theme: theme,
          formatDate: _formatDate,
          onTap: _pickDateRange,
        ),
      ],
    );
  }

  Widget _buildTypeSection(ThemeData theme) {
    final strings = t.records.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.type, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(strings.all, null, theme),
            _buildTypeChip(
              RecordType.income.displayName,
              RecordType.income,
              theme,
            ),
            _buildTypeChip(
              RecordType.expense.displayName,
              RecordType.expense,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.records.filter.categories, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryDropdown(theme),
      ],
    );
  }

  Widget _buildActions() {
    final strings = t.records.filter;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleClear,
            child: Text(strings.clear),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleApply,
            child: Text(strings.apply),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, RecordType? type, ThemeData theme) {
    final selected = _recordType == type;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _onTypeSelected(type),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: _chipLabelColor(theme, selected),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCategoryDropdownLoading() {
    return const SizedBox(
      height: 40,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildCategoryDropdownEmpty(ThemeData theme) {
    return Text(
      t.records.filter.noCategories,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildCategoryDropdownContent(
    ThemeData theme,
    List<Category> categories,
    int selectedCount,
  ) {
    final csOnSurface = theme.colorScheme.onSurface;
    final csOnSurface120 = theme.colorScheme.onSurfaceVariant;
    final csOnSurface160 = csOnSurface.withAlpha(160);
    final csOutline60 = theme.colorScheme.outline.withAlpha(60);
    final label = _categoryLabel(selectedCount, categories.length);

    return InkWell(
      onTap: () => _showCategoryDialog(context, categories),
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(color: csOutline60),
        ),
        child: Row(
          children: [
            Icon(PiconsRegular.tag, size: 20, color: csOnSurface160),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedCount > 0 ? csOnSurface : csOnSurface120,
                ),
              ),
            ),
            Icon(PiconsRegular.caretDown, size: 16, color: csOnSurface120),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) return _buildCategoryDropdownLoading();

        final categories = _visibleCategories(state.categories);
        if (categories.isEmpty) return _buildCategoryDropdownEmpty(theme);

        final selectedCount = _selectedCategoryIds.length;

        return _buildCategoryDropdownContent(theme, categories, selectedCount);
      },
    );
  }

  Widget _buildCategoryOption(Category cat, StateSetter setDialogState) {
    return CheckboxListTile(
      value: _selectedCategoryIds.contains(cat.id),
      onChanged: (val) => _onCategoryToggle(cat, val, setDialogState),
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        children: [
          CategoryTile(colorHex: cat.color, iconKey: cat.emoji, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(cat.displayName)),
        ],
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildCategoryGroupHeader(ThemeData theme, RecordType type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        type.displayName,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  List<Widget> _buildCategoryOptions(
    ThemeData theme,
    List<Category> categories,
    StateSetter setDialogState,
  ) {
    final groups = [RecordType.expense, RecordType.income]
        .map((type) => (type, categories.where((c) => c.type == type).toList()))
        .where((group) => group.$2.isNotEmpty)
        .toList();
    final showHeaders = groups.length > 1;

    return [
      for (final (type, items) in groups) ...[
        if (showHeaders) _buildCategoryGroupHeader(theme, type),
        for (final cat in items) _buildCategoryOption(cat, setDialogState),
      ],
    ];
  }

  void _showCategoryDialog(BuildContext context, List<Category> categories) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(t.records.filter.categories),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _buildCategoryOptions(
                    theme,
                    categories,
                    setDialogState,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(t.common.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Stack(
      children: [
        const _FilterBackdrop(),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Material(
                color: surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FilterHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDateRangeSection(theme),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTypeSection(theme),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCategorySection(theme),
                      const SizedBox(height: AppSpacing.lg),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBackdrop extends StatelessWidget {
  const _FilterBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withAlpha(60)),
        ),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface120 = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            t.records.filter.title,
            style: theme.textTheme.titleLarge,
          ),
        ),
        IconButton(
          icon: Icon(PiconsRegular.x, color: onSurface120),
          tooltip: t.common.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _DateRangeBox extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ThemeData theme;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _DateRangeBox({
    required this.startDate,
    required this.endDate,
    required this.theme,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sd = startDate;
    final ed = endDate;
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurface120 = colorScheme.onSurfaceVariant;
    final onSurface160 = onSurface.withAlpha(160);
    final outline60 = colorScheme.outline.withAlpha(60);
    final strings = t.records.filter;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          border: Border.all(color: outline60),
        ),
        child: Row(
          children: [
            Icon(PiconsRegular.calendar, size: 20, color: onSurface160),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                sd != null && ed != null
                    ? strings.range(start: formatDate(sd), end: formatDate(ed))
                    : strings.selectDateRange,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: sd != null ? colorScheme.onSurface : onSurface120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModalParams {
  final RecordBloc recordBloc;
  final CategoryBloc categoryBloc;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final String? recordType;
  final void Function({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    String? recordType,
  })
  onApply;
  final VoidCallback onClear;

  const FilterModalParams({
    required this.recordBloc,
    required this.categoryBloc,
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
    required this.onApply,
    required this.onClear,
  });
}

Future<void> showRecordFilterModal(
  BuildContext context,
  FilterModalParams params,
) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, anim, secondaryAnim) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: params.recordBloc),
            BlocProvider.value(value: params.categoryBloc),
          ],
          child: RecordFilterModal(
            startDate: params.startDate,
            endDate: params.endDate,
            categoryIds: params.categoryIds,
            recordType: params.recordType,
            onApply: params.onApply,
            onClear: params.onClear,
          ),
        );
      },
      transitionsBuilder: (_, anim, secondaryAnim, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    ),
  );
}
