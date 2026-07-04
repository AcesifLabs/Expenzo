import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../core/constants/record_type.dart';
import '../../../../shared/presentation/widgets/app_icons.dart';
import '../bloc/record_bloc.dart';

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
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
    );
    if (picked != null) {
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
    setState(() => _recordType = type);
  }

  Color _chipLabelColor(ThemeData theme, bool selected) {
    if (!selected) return theme.colorScheme.onSurface;

    return theme.colorScheme.onPrimary;
  }

  String _categoryLabel(int selectedCount, int totalCount) {
    if (selectedCount == 0) return 'All categories';

    if (selectedCount == totalCount) return 'All ($selectedCount)';

    return '$selectedCount selected';
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
        Text('Date Range', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Record Type', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('All', null, theme),
            _buildTypeChip('Income', RecordType.income, theme),
            _buildTypeChip('Expense', RecordType.expense, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildCategoryDropdown(theme),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleClear,
            child: const Text('Clear Filter'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleApply,
            child: const Text('Apply Filter'),
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
      'No categories',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha(100),
      ),
    );
  }

  Widget _buildCategoryDropdownContent(
    ThemeData theme,
    List<Category> categories,
    int selectedCount,
  ) {
    final csOnSurface = theme.colorScheme.onSurface;
    final csOnSurface120 = csOnSurface.withAlpha(120);
    final csOnSurface160 = csOnSurface.withAlpha(160);
    final csOutline60 = theme.colorScheme.outline.withAlpha(60);
    final label = _categoryLabel(selectedCount, categories.length);

    return InkWell(
      onTap: () => _showCategoryDialog(context, categories, theme),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: csOutline60),
        ),
        child: Row(
          children: [
            Icon(PiconsRegular.tag, size: 20, color: csOnSurface160),
            const SizedBox(width: 12),
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

        final categories = state.categories;
        if (categories.isEmpty) return _buildCategoryDropdownEmpty(theme);

        final selectedCount = _selectedCategoryIds.length;

        return _buildCategoryDropdownContent(theme, categories, selectedCount);
      },
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    List<Category> categories,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Categories'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final selected = _selectedCategoryIds.contains(cat.id);

                    return CheckboxListTile(
                      value: selected,
                      onChanged: (val) =>
                          _onCategoryToggle(cat, val, setDialogState),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Row(
                        children: [
                          Icon(
                            AppIcons.getCategoryIcon(cat.emoji),
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Done'),
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
        _FilterBackdrop(),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Material(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterHeader(),
                      const SizedBox(height: 24),
                      _buildDateRangeSection(theme),
                      const SizedBox(height: 24),
                      _buildTypeSection(theme),
                      const SizedBox(height: 24),
                      _buildCategorySection(theme),
                      const SizedBox(height: 24),
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
    final onSurface120 = theme.colorScheme.onSurface.withAlpha(120);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text('Filter Records', style: theme.textTheme.titleLarge),
        ),
        IconButton(
          icon: Icon(PiconsRegular.x, color: onSurface120),
          onPressed: () => Navigator.of(context).pop(),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
    final onSurface120 = onSurface.withAlpha(120);
    final onSurface160 = onSurface.withAlpha(160);
    final outline60 = colorScheme.outline.withAlpha(60);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outline60),
        ),
        child: Row(
          children: [
            Icon(PiconsRegular.calendar, size: 20, color: onSurface160),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sd != null && ed != null
                    ? '${formatDate(sd)} - ${formatDate(ed)}'
                    : 'Select date range',
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
