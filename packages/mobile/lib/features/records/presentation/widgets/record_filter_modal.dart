import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../core/constants/record_type.dart';
import '../../../../core/theme/app_colors.dart';
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
  }) onApply;

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
    if (widget.categoryIds != null) {
      _selectedCategoryIds.addAll(widget.categoryIds!);
    }
    if (widget.recordType != null) {
      _recordType = widget.recordType == 'IN' ? RecordType.income : RecordType.expense;
    }
    // Ensure categories are loaded
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
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
      categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
      recordType: _recordType?.dbValue,
    );
    Navigator.of(context).pop();
  }

  void _handleClear() {
    widget.onClear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Blurred background overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withAlpha(60)),
            ),
          ),
        ),
        // Modal card
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Filter Records', style: theme.textTheme.titleLarge),
                      ),
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.x(PhosphorIconsStyle.regular),
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Date Range ──
                  Text('Date Range', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                            size: 20,
                            color: theme.colorScheme.onSurface.withAlpha(160),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _startDate != null && _endDate != null
                                ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                                : 'Select date range',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _startDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Record Type ──
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
                  const SizedBox(height: 24),

                  // ── Categories ──
                  Text('Categories', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildCategoryDropdown(theme),
                  const SizedBox(height: 24),

                  // ── Buttons ──
                  Row(
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
                  ),
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

  Widget _buildTypeChip(String label, RecordType? type, ThemeData theme) {
    final selected = _recordType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _recordType = type);
      },
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? (theme.brightness == Brightness.dark ? Colors.black : AppColors.onPrimary)
            : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final categories = state.categories;
        if (categories.isEmpty) {
          return Text(
            'No categories',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          );
        }

        final selectedCount = _selectedCategoryIds.length;
        final label = selectedCount == 0
            ? 'All categories'
            : selectedCount == categories.length
                ? 'All ($selectedCount)'
                : '$selectedCount selected';

        return InkWell(
          onTap: () => _showCategoryDialog(context, categories, theme),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(60),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.tag(PhosphorIconsStyle.regular),
                  size: 20,
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedCount > 0
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
                Icon(
                  PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                  size: 16,
                  color: theme.colorScheme.onSurface.withAlpha(120),
                ),
              ],
            ),
          ),
        );
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
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedCategoryIds.add(cat.id!);
                          } else {
                            _selectedCategoryIds.remove(cat.id);
                          }
                        });
                        setDialogState(() {});
                      },
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

  String _formatDate(DateTime dt) {
    return MaterialLocalizations.of(context).formatMediumDate(dt);
  }
}

/// Show the filter modal as a full-screen overlay route with blur.
Future<void> showRecordFilterModal(
  BuildContext context, {
  required RecordBloc recordBloc,
  required CategoryBloc categoryBloc,
  DateTime? startDate,
  DateTime? endDate,
  List<String>? categoryIds,
  String? recordType,
  required void Function({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    String? recordType,
  }) onApply,
  required VoidCallback onClear,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, anim, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: recordBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: RecordFilterModal(
            startDate: startDate,
            endDate: endDate,
            categoryIds: categoryIds,
            recordType: recordType,
            onApply: onApply,
            onClear: onClear,
          ),
        );
      },
      transitionsBuilder: (_, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    ),
  );
}
