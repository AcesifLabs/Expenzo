import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../bloc/template_editor_bloc.dart';
import '../bloc/template_editor_event.dart';
import '../bloc/template_editor_state.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';
import '../widgets/retroactive_scan_dialog.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../bloc/message_sources_bloc.dart';

class TemplateEditorPage extends StatelessWidget {
  final MessageSource source;
  final SmsMessage sampleMessage;

  const TemplateEditorPage({
    super.key,
    required this.source,
    required this.sampleMessage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.getIt<TemplateEditorBloc>()),
        BlocProvider(create: (_) => di.getIt<MessageSourcesBloc>()),
      ],
      child: InteractiveTemplateBuilder(
        source: source,
        sampleMessage: sampleMessage,
      ),
    );
  }
}

class InteractiveTemplateBuilder extends StatefulWidget {
  final MessageSource source;
  final SmsMessage sampleMessage;

  const InteractiveTemplateBuilder({
    super.key,
    required this.source,
    required this.sampleMessage,
  });

  @override
  State<InteractiveTemplateBuilder> createState() =>
      _InteractiveTemplateBuilderState();
}

class _InteractiveTemplateBuilderState
    extends State<InteractiveTemplateBuilder> {
  int _step = 1;
  String? _selectedTrigger;
  String? _selectedAmount;
  List<String> _words = [];
  List<String> _numbers = [];

  ExpenseTemplate? _savedTemplate;

  static String _stripCurrencyPrefix(String amount) {
    return amount.replaceAll(
      RegExp(r'^(?:Rs\.?|INR|BDT|৳)\s*', caseSensitive: false),
      '',
    );
  }

  @override
  void initState() {
    super.initState();
    _words = widget.sampleMessage.body.split(RegExp(r'\s+'));

    final numRegex = RegExp(
      r'(?:Rs\.?|INR|BDT|৳)?\s*[\d,]+(?:\.\d+)?',
      caseSensitive: false,
    );
    _numbers = numRegex
        .allMatches(widget.sampleMessage.body)
        .map((m) => m.group(0) ?? '')
        .toList();
  }

  void _onWordSelected(String? cleanWord, bool selected) {
    setState(() {
      _selectedTrigger = selected ? cleanWord : null;
    });
  }

  void _onNumberSelected(String? number, bool selected) {
    setState(() {
      _selectedAmount = selected ? number : null;
    });
  }

  void _onNextStep(int step) {
    setState(() => _step = step);
  }

  void _onSaveTemplate() {
    final trigger = _selectedTrigger;
    final amount = _selectedAmount;
    if (trigger == null || amount == null) return;

    final amountPattern = r'(Rs\.?|INR|BDT|৳)\s*([\d,]+(?:\.\d+)?)';

    _savedTemplate = ExpenseTemplate(
      id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
      sourceId: widget.source.id,
      sampleMessage: widget.sampleMessage.body,
      triggerWord: trigger,
      amountPattern: amountPattern,
      selectedAmount: _stripCurrencyPrefix(amount),
      descriptionPattern: widget.source.contactName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final saved = _savedTemplate;
    if (saved == null) return;
    final monitoredSource = widget.source.copyWith(isMonitored: true);
    context.read<TemplateEditorBloc>().add(
      SaveTemplateEvent(saved, monitoredSource),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 1: Pick a Trigger Word',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the keyword that identifies this as an expense (e.g. "debited", "paid", "spent").',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _words.map((word) {
            final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
            if (cleanWord.isEmpty) return const SizedBox.shrink();

            return ChoiceChip(
              label: Text(
                cleanWord,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              selected: _selectedTrigger == cleanWord,
              onSelected: (selected) => _onWordSelected(cleanWord, selected),
            );
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _selectedTrigger != null ? () => _onNextStep(2) : null,
          child: const Text('Next: Select Amount'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 2: Select the Amount',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Which of these numbers is the expense amount?'),
        const SizedBox(height: 24),
        if (_numbers.isEmpty)
          Text(
            'No numbers found in this message.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else
          _buildNumberChips(),
        const Spacer(),
        Row(
          children: [
            TextButton(
              onPressed: () => _onNextStep(1),
              child: const Text('Back'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedAmount != null ? () => _onNextStep(3) : null,
              child: const Text('Next: Review'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberChips() {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _numbers.map((number) {
        final displayAmount = _stripCurrencyPrefix(number);

        return ChoiceChip(
          label: Text(
            displayAmount,
            style: TextStyle(fontSize: 18, color: colors.onSurface),
          ),
          selected: _selectedAmount == number,
          selectedColor: Theme.of(context).colorScheme.secondaryContainer,
          onSelected: (selected) => _onNumberSelected(number, selected),
        );
      }).toList(),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 3: Review',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildReviewCard(),
        const SizedBox(height: 16),
        const Text(
          'In the future, the app will automatically create expenses '
          'when it sees messages containing this trigger word.',
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            TextButton(
              onPressed: () => _onNextStep(2),
              child: const Text('Back'),
            ),
            const Spacer(),
            BlocConsumer<TemplateEditorBloc, TemplateEditorState>(
              listener: _onTemplateSaveState,
              builder: (context, state) {
                if (state is TemplateEditorSaving) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: _onSaveTemplate,
                  child: const Text('Save & Finish'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sender', style: TextStyle(color: colors.onSurfaceVariant)),
            Text(
              widget.source.contactName,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Trigger Word',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            Text(
              _selectedTrigger ?? '',
              style: TextStyle(fontSize: 18, color: colors.tertiary),
            ),
            const SizedBox(height: 16),
            Text(
              'Sample Amount',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            Text(
              _stripCurrencyPrefix(_selectedAmount ?? ''),
              style: TextStyle(fontSize: 18, color: colors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  void _onTemplateSaveState(BuildContext context, TemplateEditorState state) {
    final saved = _savedTemplate;
    switch (state) {
      case TemplateEditorSaved() when saved != null:
        unawaited(_handleSaveSuccess(context, saved));
      case TemplateEditorError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving template: $message'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      default:
        break;
    }
  }

  Future<void> _handleSaveSuccess(
    BuildContext context,
    ExpenseTemplate saved,
  ) async {
    await showRetroactiveScanDialog(context, widget.source, saved);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildCurrentStep() {
    if (_step == 1) return _buildStep1();
    if (_step == 2) return _buildStep2();

    return _buildStep3();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Template')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }
}
