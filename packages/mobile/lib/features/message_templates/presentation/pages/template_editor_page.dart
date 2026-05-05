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
  late List<String> _words;
  late List<String> _numbers;

  @override
  void initState() {
    super.initState();
    // Split message by spaces or newlines to create bubbles
    _words = widget.sampleMessage.body.split(RegExp(r'\s+'));

    // Extract all numbers/currencies
    final numRegex = RegExp(
      r'(?:Rs\.?|INR|BDT|৳)?\s*[\d,]+(?:\.\d+)?',
      caseSensitive: false,
    );
    _numbers = numRegex
        .allMatches(widget.sampleMessage.body)
        .map((m) => m.group(0) ?? '')
        .toList();
  }

  ExpenseTemplate? _savedTemplate;

  void _generateAndSaveTemplate() {
    if (_selectedTrigger == null || _selectedAmount == null) return;

    // Pattern requires currency prefix (Rs, INR, BDT, ৳) to distinguish amounts from IDs/numbers
    final amountPattern = r'(Rs\.?|INR|BDT|৳)\s*([\d,]+(?:\.\d+)?)';

    _savedTemplate = ExpenseTemplate(
      id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
      sourceId: widget.source.id,
      sampleMessage: widget.sampleMessage.body,
      triggerWord: _selectedTrigger!,
      amountPattern: amountPattern,
      // Store numeric portion only (without currency prefix) for reliable comparison
      selectedAmount: _stripCurrencyPrefix(_selectedAmount!),
      descriptionPattern: widget.source.contactName, // Default to sender name
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Also pass the MessageSource so the Bloc can save it first to satisfy foreign key
    final monitoredSource = widget.source.copyWith(isMonitored: true);
    context.read<TemplateEditorBloc>().add(
      SaveTemplateEvent(_savedTemplate!, monitoredSource),
    );
  }

  Widget _buildStep1() {
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

            final isSelected = _selectedTrigger == cleanWord;
            final isLight = Theme.of(context).brightness == Brightness.light;

            return ChoiceChip(
              label: Text(
                cleanWord,
                style: TextStyle(color: isLight ? Colors.black : null),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTrigger = selected ? cleanWord : null;
                });
              },
            );
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _selectedTrigger != null
              ? () => setState(() => _step = 2)
              : null,
          child: const Text('Next: Select Amount'),
        ),
      ],
    );
  }

  static String _stripCurrencyPrefix(String amount) {
    // Remove common currency prefixes/symbols and whitespace for display
    return amount.replaceAll(
      RegExp(r'^(?:Rs\.?|INR|BDT|৳)\s*', caseSensitive: false),
      '',
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
          const Text(
            'No numbers found in this message.',
            style: TextStyle(color: Colors.red),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _numbers.map((number) {
              final isSelected = _selectedAmount == number;
              final displayAmount = _stripCurrencyPrefix(number);
              final isLight = Theme.of(context).brightness == Brightness.light;

              return ChoiceChip(
                label: Text(
                  displayAmount,
                  style: TextStyle(
                    fontSize: 18,
                    color: isLight ? Colors.black : null,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.green.shade100,
                onSelected: (selected) {
                  setState(() {
                    _selectedAmount = selected ? number : null;
                  });
                },
              );
            }).toList(),
          ),
        const Spacer(),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Back'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedAmount != null
                  ? () => setState(() => _step = 3)
                  : null,
              child: const Text('Next: Review'),
            ),
          ],
        ),
      ],
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sender', style: TextStyle(color: Colors.grey)),
                Text(
                  widget.source.contactName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trigger Word',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  _selectedTrigger ?? '',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sample Amount',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  _stripCurrencyPrefix(_selectedAmount ?? ''),
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
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
              onPressed: () => setState(() => _step = 2),
              child: const Text('Back'),
            ),
            const Spacer(),
            BlocConsumer<TemplateEditorBloc, TemplateEditorState>(
              listener: (context, state) async {
                if (state is TemplateEditorSaved && _savedTemplate != null) {
                  // Show the retroactive scan dialog first
                  await RetroactiveScanDialog.show(
                    context,
                    widget.source,
                    _savedTemplate!,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Template saved successfully!'),
                      ),
                    );
                    Navigator.of(context).pop(); // Back to templates list
                  }
                } else if (state is TemplateEditorError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving template: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TemplateEditorSaving) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: _generateAndSaveTemplate,
                  child: const Text('Save & Finish'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Template')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 1
              ? _buildStep1()
              : _step == 2
              ? _buildStep2()
              : _buildStep3(),
        ),
      ),
    );
  }
}
