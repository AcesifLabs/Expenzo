import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../../../shared/presentation/widgets/shimmer_box.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../domain/entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';

class RecordFormPage extends StatefulWidget {
  final Record? record;
  final RecordType? initialType;

  const RecordFormPage({super.key, this.record, this.initialType});

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  late RecordType _recordType;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.record != null ? widget.record!.amount.abs().toString() : '',
    );
    _descriptionController = TextEditingController(
      text: widget.record?.description ?? '',
    );
    _selectedDate = widget.record?.date ?? DateTime.now();
    _selectedCategoryId = widget.record?.categoryId;
    _recordType =
        widget.record?.recordType ?? widget.initialType ?? RecordType.expense;

    context.read<CategoryBloc>().add(LoadCategories(type: _recordType));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? 'Edit ${_recordType.displayName}'
        : 'New ${_recordType.displayName}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText:
                    'What was this ${_recordType.displayName.toLowerCase()} for?',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading || state is CategoryInitial) {
                  return ShimmerBox.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: 12,
                  );
                }
                if (state is CategoryError) {
                  return Text('Error: ${state.message}');
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No categories available. Create one first.'),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No Category'),
                      ),
                      ...state.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.getCategoryIcon(cat.emoji),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                    key: ValueKey('category_dropdown_$_recordType'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_dateFormat.format(_selectedDate)),
              trailing: Icon(PiconsRegular.calendar),
              onTap: _selectDate,
            ),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toUtc();
      final rawAmount = double.parse(_amountController.text).abs();

      final finalAmount = _recordType == RecordType.expense
          ? -rawAmount
          : rawAmount;

      final record = Record(
        id: widget.record?.id,
        amount: finalAmount,
        description: _descriptionController.text,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        source: ExpenseSource.manual,
        recordType: _recordType,
        createdAt: widget.record?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        context.read<RecordBloc>().add(UpdateRecordEvent(record));
      } else {
        context.read<RecordBloc>().add(AddRecordEvent(record));
      }
      Navigator.pop(context);
    }
  }
}
