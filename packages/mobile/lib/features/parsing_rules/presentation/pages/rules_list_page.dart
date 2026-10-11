import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:picons/picons.dart';
import '../../data/datasources/default_rules_templates.dart';
import '../../domain/entities/parsing_rule.dart';
import '../bloc/parsing_rules_bloc.dart';
import '../bloc/parsing_rules_event.dart';
import '../bloc/parsing_rules_state.dart';
import '../widgets/rule_card.dart';
import '../widgets/regex_tester_widget.dart';
import '../widgets/regex_pattern_validator.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class RulesListPage extends StatelessWidget {
  const RulesListPage({super.key});

  void _navigateToTemplates(BuildContext context) {
    Navigator.of(context).push(
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ParsingRulesBloc>(),
          child: const AddTemplatesPage(),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, [ParsingRule? rule]) {
    Navigator.of(context).push(
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ParsingRulesBloc>(),
          child: RuleEditorPage(rule: rule),
        ),
      ),
    );
  }

  IconButton _buildAddTemplateButton(BuildContext context) {
    return IconButton(
      icon: const Icon(PiconsRegular.listPlus),
      tooltip: t.parsingRules.addFromFormats,
      onPressed: () => _navigateToTemplates(context),
    );
  }

  IconButton _buildAddRuleButton(BuildContext context) {
    return IconButton(
      icon: const Icon(PiconsRegular.plus),
      tooltip: t.parsingRules.newRule,
      onPressed: () => _navigateToEditor(context),
    );
  }

  Widget _buildBody(BuildContext context, ParsingRulesState state) {
    return switch (state) {
      ParsingRulesLoading() => const Center(child: CircularProgressIndicator()),
      ParsingRulesError(:final message) => _buildError(context, message),
      ParsingRulesLoaded(:final rules) when rules.isEmpty => _buildEmptyState(
        context,
      ),
      ParsingRulesLoaded(:final rules) => _buildRulesList(rules, context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => context.read<ParsingRulesBloc>().add(LoadRules()),
            child: Text(t.common.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final strings = t.parsingRules.empty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PiconsRegular.listChecks,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(strings.title, style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(PiconsRegular.plus),
              label: Text(strings.add),
              onPressed: () => _navigateToEditor(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefreshRules(BuildContext context) {
    context.read<ParsingRulesBloc>().add(RefreshRules());

    return Future<void>.value();
  }

  Widget _buildRulesList(List<ParsingRule> rules, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefreshRules(context),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: rules.length,
        itemBuilder: (context, index) => _buildRuleItem(context, rules[index]),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, ParsingRule rule) {
    return RuleCard(
      rule: rule,
      onToggle: (isEnabled) => _onToggleRule(context, rule, isEnabled),
      onTap: () => _navigateToEditor(context, rule),
      onDelete: () => _onDeleteRule(context, rule),
    );
  }

  void _onToggleRule(BuildContext context, ParsingRule rule, bool isEnabled) {
    context.read<ParsingRulesBloc>().add(
      ToggleRule(ruleId: rule.id, isEnabled: isEnabled),
    );
  }

  void _onDeleteRule(BuildContext context, ParsingRule rule) {
    context.read<ParsingRulesBloc>().add(DeleteRuleRequested(ruleId: rule.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: t.common.matchingRules,
        actions: [
          _buildAddTemplateButton(context),
          _buildAddRuleButton(context),
        ],
      ),
      body: BlocBuilder<ParsingRulesBloc, ParsingRulesState>(
        builder: _buildBody,
      ),
    );
  }
}

class RuleEditorPage extends StatefulWidget {
  final ParsingRule? rule;

  const RuleEditorPage({super.key, this.rule});

  @override
  State<RuleEditorPage> createState() => _RuleEditorPageState();
}

class _RuleEditorPageState extends State<RuleEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _triggerWordsController = TextEditingController();
  final TextEditingController _amountPatternController =
      TextEditingController();
  final TextEditingController _datePatternController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  SourceType _sourceType = SourceType.sms;
  String? _categoryId;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _populateFromRule();
  }

  void _populateFromRule() {
    final rule = widget.rule;
    if (rule != null) {
      _nameController.text = rule.name;
      _triggerWordsController.text = rule.triggerWords.join(', ');
      _amountPatternController.text = rule.amountPattern;
      _datePatternController.text = rule.datePattern ?? '';
      _priorityController.text = rule.priority.toString();
      _sourceType = rule.sourceType;
      _categoryId = rule.categoryId;
      _isEnabled = rule.isEnabled;
    }
  }

  ParsingRule _buildRule() {
    final now = DateTime.now();
    final triggerWords = _triggerWordsController.text
        .split(',')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
    final datePattern = _datePatternController.text.trim();

    return ParsingRule(
      id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      triggerWords: triggerWords,
      amountPattern: _amountPatternController.text.trim(),
      datePattern: datePattern.isEmpty ? null : datePattern,
      categoryId: _categoryId,
      sourceType: _sourceType,
      isEnabled: _isEnabled,
      priority: int.tryParse(_priorityController.text) ?? 0,
      createdAt: widget.rule?.createdAt ?? now,
      updatedAt: now,
    );
  }

  void _saveRule() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final rule = _buildRule();

    context.read<ParsingRulesBloc>().add(CreateRuleEvent(rule));

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.rule == null
                ? t.parsingRules.created
                : t.parsingRules.updated,
          ),
        ),
      );

    Navigator.of(context).pop();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.parsingRules.validation.nameRequired;
    }

    return null;
  }

  String? _validateTriggerWords(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.parsingRules.validation.triggerRequired;
    }

    return null;
  }

  String? _validateAmountPattern(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.parsingRules.validation.amountRequired;
    }
    try {
      RegExp(value);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return t.parsingRules.validation.invalidRegex;
    }

    return null;
  }

  void _onSourceTypeChanged(Set<SourceType> selection) {
    setState(() {
      _sourceType = selection.first;
    });
  }

  void _onEnabledChanged(bool value) {
    setState(() {
      _isEnabled = value;
    });
  }

  TextFormField _buildNameField() {
    final form = t.parsingRules.form;

    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: form.name,
        hintText: form.nameHint,
        border: OutlineInputBorder(),
      ),
      validator: _validateName,
    );
  }

  TextFormField _buildTriggerWordsField() {
    final form = t.parsingRules.form;

    return TextFormField(
      controller: _triggerWordsController,
      decoration: InputDecoration(
        labelText: form.keyWords,
        hintText: form.keyWordsHint,
        border: OutlineInputBorder(),
        helperText: form.keyWordsHelper,
      ),
      validator: _validateTriggerWords,
    );
  }

  Column _buildAmountPatternSection() {
    final form = t.parsingRules.form;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          form.amountPattern,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        RegexValidatorIndicator(pattern: _amountPatternController.text),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _amountPatternController,
          decoration: InputDecoration(
            labelText: form.amountRegex,
            hintText: r'Rs\.?\s*([\d,]+\.?\d*)',
            border: OutlineInputBorder(),
            helperText:
                r'Use capture group () for amount value. Example: Rs\.?\s*([\d,]+\.?\d*)',
          ),
          validator: _validateAmountPattern,
        ),
        const SizedBox(height: AppSpacing.sm),
        RegexTesterWidget(
          pattern: _amountPatternController.text,
          datePattern: _datePatternController.text,
        ),
      ],
    );
  }

  Column _buildDatePatternSection() {
    final form = t.parsingRules.form;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          form.datePattern,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _datePatternController,
          decoration: InputDecoration(
            labelText: form.dateRegex,
            hintText: r'(\d{2}/\d{2}/\d{4})',
            border: OutlineInputBorder(),
            helperText: form.dateHelper,
          ),
        ),
      ],
    );
  }

  Column _buildSourceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.parsingRules.form.source,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<SourceType>(
          segments: [
            ButtonSegment(
              value: SourceType.sms,
              label: Text(SourceType.sms.displayName),
              icon: const Icon(PiconsRegular.chatText),
            ),
            ButtonSegment(
              value: SourceType.email,
              label: Text(SourceType.email.displayName),
              icon: const Icon(PiconsRegular.envelope),
            ),
            ButtonSegment(
              value: SourceType.both,
              label: Text(SourceType.both.displayName),
              icon: const Icon(PiconsRegular.arrowsClockwise),
            ),
          ],
          selected: {_sourceType},
          onSelectionChanged: _onSourceTypeChanged,
        ),
      ],
    );
  }

  TextFormField _buildPriorityField() {
    final form = t.parsingRules.form;

    return TextFormField(
      controller: _priorityController,
      decoration: InputDecoration(
        labelText: form.priority,
        hintText: '0',
        border: OutlineInputBorder(),
        helperText: form.priorityHelper,
      ),
      keyboardType: TextInputType.number,
    );
  }

  SwitchListTile _buildEnabledSwitch() {
    final form = t.parsingRules.form;

    return SwitchListTile(
      title: Text(form.enabled),
      subtitle: Text(form.enabledDetail),
      value: _isEnabled,
      onChanged: _onEnabledChanged,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _triggerWordsController.dispose();
    _amountPatternController.dispose();
    _datePatternController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rule != null;

    return Scaffold(
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: isEditing ? t.parsingRules.editRule : t.parsingRules.newRule,
        actions: [TextButton(onPressed: _saveRule, child: Text(t.common.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildNameField(),
            const SizedBox(height: AppSpacing.md),
            _buildTriggerWordsField(),
            const SizedBox(height: AppSpacing.lg),
            _buildAmountPatternSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildDatePatternSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildSourceTypeSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildPriorityField(),
            const SizedBox(height: AppSpacing.md),
            _buildEnabledSwitch(),
          ],
        ),
      ),
    );
  }
}

class AddTemplatesPage extends StatelessWidget {
  const AddTemplatesPage({super.key});

  /// Translation key for a built-in template ("HDFC Bank SMS" → hdfc_bank_sms).
  static String _templateKey(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Card _buildTemplateCard(BuildContext context, DefaultRuleTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            template.sourceType == SourceType.sms
                ? PiconsRegular.chatText
                : PiconsRegular.envelope,
          ),
        ),
        title: Text(template.name),
        subtitle: Text(
          t.parsingRules.templates[_templateKey(template.name)] ??
              template.description,
        ),
        trailing: ElevatedButton(
          onPressed: () => _addTemplate(context, template),
          child: Text(t.parsingRules.add),
        ),
      ),
    );
  }

  void _addTemplate(BuildContext context, DefaultRuleTemplate template) {
    final rule = template.toParsingRule();
    context.read<ParsingRulesBloc>().add(CreateRuleEvent(rule));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(t.parsingRules.added(name: template.name))),
      );
  }

  @override
  Widget build(BuildContext context) {
    const templates = DefaultRulesTemplates.templates;

    return Scaffold(
      appBar: AppPageHeader(
        leading: AppBackButton(),
        title: t.parsingRules.addFromFormats,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: templates.length,
        itemBuilder: (context, index) =>
            _buildTemplateCard(context, templates[index]),
      ),
    );
  }
}
