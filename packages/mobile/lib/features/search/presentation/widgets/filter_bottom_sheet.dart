import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import '../../domain/entities/search_filters.dart';

class FilterBottomSheet extends StatefulWidget {
  static Future<void> show({
    required BuildContext context,
    required SearchFilters currentFilters,
    required ValueChanged<SearchFilters> onFiltersChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        currentFilters: currentFilters,
        onFiltersChanged: onFiltersChanged,
      ),
    );
  }

  final SearchFilters currentFilters;
  final ValueChanged<SearchFilters> onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  SearchFilters _filters = const SearchFilters();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    if (_filters.minAmount != null) {
      _minAmountController.text = _filters.minAmount.toString();
    }
    if (_filters.maxAmount != null) {
      _maxAmountController.text = _filters.maxAmount.toString();
    }
    _startDate = _filters.dateRange?.start;
    _endDate = _filters.dateRange?.end;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDateRangePickers() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final buttonStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
    final startDate = _startDate;
    final endDate = _endDate;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(true),
            style: buttonStyle,
            child: Text(
              startDate != null ? dateFormat.format(startDate) : 'Start Date',
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('-'),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(false),
            style: buttonStyle,
            child: Text(
              endDate != null ? dateFormat.format(endDate) : 'End Date',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildAmountRange() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Min Amount',
              border: OutlineInputBorder(),
              prefixText: '৳ ',
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('-'),
        ),
        Expanded(
          child: TextField(
            controller: _maxAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max Amount',
              border: OutlineInputBorder(),
              prefixText: '৳ ',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _applyFilters,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
        ),
        child: const Text('Apply Filters'),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
    widget.onFiltersChanged(const SearchFilters());
    Navigator.pop(context);
  }

  void _applyFilters() {
    DateRange? dateRange;
    final startDate = _startDate;
    final endDate = _endDate;
    if (startDate != null && endDate != null) {
      dateRange = DateRange(start: startDate, end: endDate);
    }

    final minAmount = _minAmountController.text.isNotEmpty
        ? double.tryParse(_minAmountController.text)
        : null;
    final maxAmount = _maxAmountController.text.isNotEmpty
        ? double.tryParse(_maxAmountController.text)
        : null;

    final newFilters = SearchFilters(
      query: _filters.query,
      categoryId: _filters.categoryId,
      dateRange: dateRange,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    widget.onFiltersChanged(newFilters);
    Navigator.pop(context);
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: _clearAll, child: const Text('Clear All')),
      ],
    );
  }

  Widget _buildFilterContent(ScrollController scrollController) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        children: [
          _buildSectionTitle('Date Range'),
          _buildDateRangePickers(),
          const SizedBox(height: 24),
          _buildSectionTitle('Amount Range'),
          _buildAmountRange(),
          const SizedBox(height: 24),
          _buildApplyButton(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilterContent(scrollController),
            ],
          ),
        );
      },
    );
  }
}
