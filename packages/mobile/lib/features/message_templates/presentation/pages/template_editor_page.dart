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
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import '../widgets/template_editor_components.dart';
import '../bloc/message_sources_bloc.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Words from an SMS that can identify its type, in message order.
///
/// Punctuation is trimmed only at the edges so "A/C" stays "A/C" and the word
/// still matches the message text (templates match with `contains`). Plain
/// numbers and amounts ("450.00", "9,550") are left out: they change between
/// messages, so they can't identify one. Repeats are shown once.
List<String> triggerWordCandidates(String body) {
  final edgePunctuation = RegExp(
    r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$',
    unicode: true,
  );
  final numberOnly = RegExp(r'^[\d.,:/-]+$');
  final seen = <String>{};
  final words = <String>[];
  for (final token in body.split(RegExp(r'\s+'))) {
    final word = token.replaceAll(edgePunctuation, '');
    if (word.isEmpty || numberOnly.hasMatch(word)) continue;
    if (seen.add(word.toLowerCase())) words.add(word);
  }

  return words;
}

class TemplateEditorPage extends StatelessWidget {
  final MessageSource source;
  final SmsMessage sampleMessage;

  /// When provided, the page enters edit-mode: trigger word and amount
  /// are pre-filled from this template, the AppBar title says
  /// "Edit Template", the row id is preserved so save upserts the
  /// existing row, and the post-save retroactive-scan dialog is
  /// skipped. When null, the page is in create-mode.
  final ExpenseTemplate? existingTemplate;

  const TemplateEditorPage({
    super.key,
    required this.source,
    required this.sampleMessage,
    this.existingTemplate,
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
        existingTemplate: existingTemplate,
      ),
    );
  }
}

class InteractiveTemplateBuilder extends StatefulWidget {
  final MessageSource source;
  final SmsMessage sampleMessage;
  final ExpenseTemplate? existingTemplate;

  const InteractiveTemplateBuilder({
    super.key,
    required this.source,
    required this.sampleMessage,
    this.existingTemplate,
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
    return amount
        .replaceAll(
          RegExp(
            r'^(?:Tk|Rs\.?|RM|INR|BDT|PKR|LKR|NPR|USD|GBP|EUR|[$€£৳₹])\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  @override
  void initState() {
    super.initState();
    final body = widget.sampleMessage.body;
    _words = triggerWordCandidates(body);

    // Matches optional currency prefix (Tk, Rs, USD, etc.) followed by a
    // number with optional thousands-separator commas and decimal part.
    final numRegex = RegExp(
      r'(?:[A-Z]{2,4}[\s.]*|[$€£৳₹]\s*)?([\d][\d,]*\.\d+|[\d]+)',
      caseSensitive: false,
    );
    _numbers = numRegex.allMatches(body).map((m) => m.group(0) ?? '').toList();

    _applyExistingTemplatePrefill();
  }

  /// In edit-mode, pre-select the previously chosen trigger word and
  /// amount so the user can either accept or revise.
  void _applyExistingTemplatePrefill() {
    final existing = widget.existingTemplate;
    if (existing == null) return;

    _selectedTrigger = existing.triggerWord;

    final savedStripped = existing.selectedAmount;
    if (savedStripped != null) {
      for (final raw in _numbers) {
        if (_stripCurrencyPrefix(raw) == savedStripped) {
          _selectedAmount = raw;

          break;
        }
      }
      // If the previous amount isn't in this message body (rare), leave
      // _selectedAmount null so the user re-picks on Step 2.
    }

    // Open at Step 3 (Review) in edit-mode so the user sees the live
    // values they just loaded and can either accept or step back to
    // adjust. Create-mode still opens at Step 1.
    _step = 3;
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

    // Currency prefix is optional so patterns like "Tk 1,000.00" or bare
    // "1,000.00" both match.  Group 1 = amount, group 2 = decimal variant.
    const amountPattern =
        r'(?:[A-Z]{2,4}[\s.]*|[$€£৳₹]\s*)?([\d][\d,]*\.\d+|[\d]+)';

    final existing = widget.existingTemplate;
    final now = DateTime.now();

    _savedTemplate = ExpenseTemplate(
      // Preserve id in edit-mode so save upserts the same row.
      id: existing?.id ?? 'tmpl_${now.millisecondsSinceEpoch}',
      sourceId: widget.source.id,
      sampleMessage: widget.sampleMessage.body,
      triggerWord: trigger,
      amountPattern: amountPattern,
      selectedAmount: _stripCurrencyPrefix(amount),
      descriptionPattern:
          existing?.descriptionPattern ?? widget.source.contactName,
      datePattern: existing?.datePattern,
      categoryId: existing?.categoryId,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final saved = _savedTemplate;
    if (saved == null) return;
    final monitoredSource = widget.source.copyWith(isMonitored: true);
    context.read<TemplateEditorBloc>().add(
      SaveTemplateEvent(saved, monitoredSource),
    );
  }

  Widget _buildStepScaffold({
    required String stepKey,
    required List<Widget> content,
    required Widget actions,
  }) {
    return Column(
      key: ValueKey(stepKey),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepProgressIndicator(currentStep: _step),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...content,
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        actions,
      ],
    );
  }

  Widget _buildTriggerChipList() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _words.map((word) {
        return TriggerWordChip(
          word: word,
          isSelected: _selectedTrigger == word,
          onTap: () => _onWordSelected(word, _selectedTrigger != word),
        );
      }).toList(),
    );
  }

  Widget _buildAmountList() {
    if (_numbers.isEmpty) {
      return Text(
        t.messageTemplates.editor.noNumbers,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.messageTemplates.editor.amountsFound,
          style: AppTypography.bodyMedium.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Column(
          children: _numbers.map((number) {
            final displayAmount = _stripCurrencyPrefix(number);
            final isSelected = _selectedAmount == number;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AmountRow(
                amount: displayAmount,
                isSelected: isSelected,
                onTap: () => _onNumberSelected(number, !isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Says why the step's button is disabled, right above it.
  Widget _withHint({required String? hint, required Widget child}) {
    if (hint == null) return child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hint,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  Widget _buildStep1() {
    final editorT = t.messageTemplates.editor;
    final palette = context.palette;

    return _buildStepScaffold(
      stepKey: 'step1',
      content: [
        Text(
          editorT.step1,
          style: AppTypography.titleLarge.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          editorT.step1Body,
          style: AppTypography.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        MessagePreviewCard(
          senderName: widget.source.contactName,
          messageBody: widget.sampleMessage.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          editorT.wordsInMessage,
          style: AppTypography.labelLarge.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTriggerChipList(),
      ],
      actions: _withHint(
        hint: _selectedTrigger == null ? editorT.step1Hint : null,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTrigger != null ? () => _onNextStep(2) : null,
            child: Text(t.common.next),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final editorT = t.messageTemplates.editor;
    final palette = context.palette;
    final commonT = t.common;

    return _buildStepScaffold(
      stepKey: 'step2',
      content: [
        Text(
          editorT.step2,
          style: AppTypography.titleLarge.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          editorT.step2Body,
          style: AppTypography.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        MessagePreviewCard(
          senderName: widget.source.contactName,
          messageBody: widget.sampleMessage.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildAmountList(),
      ],
      actions: _withHint(
        hint: _selectedAmount == null ? editorT.step2Hint : null,
        child: Row(
          children: [
            TextButton(
              onPressed: () => _onNextStep(1),
              child: Text(commonT.back),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedAmount != null ? () => _onNextStep(3) : null,
              child: Text(commonT.next),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final editorT = t.messageTemplates.editor;
    final palette = context.palette;
    final commonT = t.common;

    return _buildStepScaffold(
      stepKey: 'step3',
      content: [
        Text(
          editorT.step3,
          style: AppTypography.titleLarge.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildReviewCard(),
        const SizedBox(height: AppSpacing.md),
        Text(
          editorT.step3Body,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
        ),
      ],
      actions: Row(
        children: [
          TextButton(
            onPressed: () => _onNextStep(2),
            child: Text(commonT.back),
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
                child: Text(commonT.save),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewField(String label, String value, TextStyle valueStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildReviewCard() {
    final editorT = t.messageTemplates.editor;
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewField(
            editorT.sender,
            widget.source.contactName,
            AppTypography.titleMedium.copyWith(color: palette.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildReviewField(
            editorT.keyWord,
            _selectedTrigger ?? '',
            AppTypography.titleMedium.copyWith(color: palette.brand),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildReviewField(
            editorT.amountInMessage,
            _stripCurrencyPrefix(_selectedAmount ?? ''),
            AppTypography.titleMedium.copyWith(color: palette.income),
          ),
        ],
      ),
    );
  }

  void _onTemplateSaveState(BuildContext context, TemplateEditorState state) {
    final saved = _savedTemplate;
    switch (state) {
      case TemplateEditorSaved() when saved != null:
        unawaited(_handleSaveSuccess(context, saved));
      case TemplateEditorError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                t.messageTemplates.editor.saveFailed(reason: message),
              ),
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
    final isEdit = widget.existingTemplate != null;

    // Edit-mode skips the retroactive scan: editing doesn't generate
    // new candidate messages. Create-mode keeps the existing flow.
    if (!isEdit) {
      await showRetroactiveScanDialog(context, widget.source, saved);
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? t.messageTemplates.editor.updated
                : t.messageTemplates.editor.saved,
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  Widget _buildCurrentStep() {
    if (_step == 1) return _buildStep1();
    if (_step == 2) return _buildStep2();

    return _buildStep3();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.bg,
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: widget.existingTemplate != null
            ? t.messageTemplates.edit
            : t.messageTemplates.create,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }
}
