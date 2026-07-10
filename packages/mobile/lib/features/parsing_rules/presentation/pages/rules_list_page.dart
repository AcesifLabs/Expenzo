import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../../data/datasources/default_rules_templates.dart';
import '../../domain/entities/parsing_rule.dart';
import '../bloc/parsing_rules_bloc.dart';
import '../bloc/parsing_rules_event.dart';
import '../bloc/parsing_rules_state.dart';
import '../widgets/rule_card.dart';
import '../widgets/regex_tester_widget.dart';
import '../widgets/regex_pattern_validator.dart';

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
      icon: const Icon(Icons.library_add),
      tooltip: 'Add templates',
      onPressed: () => _navigateToTemplates(context),
    );
  }

  IconButton _buildAddRuleButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
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
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ParsingRulesBloc>().add(LoadRules()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rule,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No rules yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add one to start parsing SMS and emails automatically!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Rule'),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
      appBar: AppBar(
        title: const Text('Parsing Rules'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.rule == null ? 'Rule created' : 'Rule updated'),
      ),
    );

    Navigator.of(context).pop();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  String? _validateTriggerWords(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'At least one trigger word is required';
    }

    return null;
  }

  String? _validateAmountPattern(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount pattern is required';
    }
    try {
      RegExp(value);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return 'Invalid regex pattern';
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
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Rule Name *',
        hintText: 'e.g., HDFC Bank SMS',
        border: OutlineInputBorder(),
      ),
      validator: _validateName,
    );
  }

  TextFormField _buildTriggerWordsField() {
    return TextFormField(
      controller: _triggerWordsController,
      decoration: const InputDecoration(
        labelText: 'Trigger Words *',
        hintText: 'HDFC, debit, account (comma-separated)',
        border: OutlineInputBorder(),
        helperText: 'Words that indicate this rule should be tried',
      ),
      validator: _validateTriggerWords,
    );
  }

  Column _buildAmountPatternSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount Pattern (Regex) *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RegexValidatorIndicator(pattern: _amountPatternController.text),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountPatternController,
          decoration: const InputDecoration(
            labelText: 'Amount Regex',
            hintText: r'Rs\.?\s*([\d,]+\.?\d*)',
            border: OutlineInputBorder(),
            helperText:
                r'Use capture group () for amount value. Example: Rs\.?\s*([\d,]+\.?\d*)',
          ),
          validator: _validateAmountPattern,
        ),
        const SizedBox(height: 8),
        RegexTesterWidget(
          pattern: _amountPatternController.text,
          datePattern: _datePatternController.text,
        ),
      ],
    );
  }

  Column _buildDatePatternSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Pattern (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _datePatternController,
          decoration: const InputDecoration(
            labelText: 'Date Regex (Optional)',
            hintText: r'(\d{2}/\d{2}/\d{4})',
            border: OutlineInputBorder(),
            helperText: 'Leave empty if date is not needed',
          ),
        ),
      ],
    );
  }

  Column _buildSourceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Source Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<SourceType>(
          segments: const [
            ButtonSegment(
              value: SourceType.sms,
              label: Text('SMS'),
              icon: Icon(Icons.sms),
            ),
            ButtonSegment(
              value: SourceType.email,
              label: Text('Email'),
              icon: Icon(Icons.email),
            ),
            ButtonSegment(
              value: SourceType.both,
              label: Text('Both'),
              icon: Icon(Icons.sync),
            ),
          ],
          selected: {_sourceType},
          onSelectionChanged: _onSourceTypeChanged,
        ),
      ],
    );
  }

  TextFormField _buildPriorityField() {
    return TextFormField(
      controller: _priorityController,
      decoration: const InputDecoration(
        labelText: 'Priority',
        hintText: '0',
        border: OutlineInputBorder(),
        helperText: 'Higher priority rules are tried first',
      ),
      keyboardType: TextInputType.number,
    );
  }

  SwitchListTile _buildEnabledSwitch() {
    return SwitchListTile(
      title: const Text('Enabled'),
      subtitle: const Text('Enable this rule for parsing'),
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rule' : 'New Rule'),
        actions: [TextButton(onPressed: _saveRule, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildTriggerWordsField(),
            const SizedBox(height: 24),
            _buildAmountPatternSection(),
            const SizedBox(height: 24),
            _buildDatePatternSection(),
            const SizedBox(height: 24),
            _buildSourceTypeSection(),
            const SizedBox(height: 24),
            _buildPriorityField(),
            const SizedBox(height: 16),
            _buildEnabledSwitch(),
          ],
        ),
      ),
    );
  }
}

class AddTemplatesPage extends StatelessWidget {
  const AddTemplatesPage({super.key});

  Card _buildTemplateCard(BuildContext context, DefaultRuleTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            template.sourceType == SourceType.sms ? Icons.sms : Icons.email,
          ),
        ),
        title: Text(template.name),
        subtitle: Text(template.description),
        trailing: ElevatedButton(
          onPressed: () => _addTemplate(context, template),
          child: const Text('Add'),
        ),
      ),
    );
  }

  void _addTemplate(BuildContext context, DefaultRuleTemplate template) {
    final rule = template.toParsingRule();
    context.read<ParsingRulesBloc>().add(CreateRuleEvent(rule));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added "${template.name}"')));
  }

  @override
  Widget build(BuildContext context) {
    final templates = DefaultRulesTemplates.templates;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Template Rules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, index) =>
            _buildTemplateCard(context, templates[index]),
      ),
    );
  }
}
