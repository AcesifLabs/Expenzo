import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parsing Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add),
            tooltip: 'Add templates',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ParsingRulesBloc>(),
                    child: const AddTemplatesPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ParsingRulesBloc>(),
                    child: const RuleEditorPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ParsingRulesBloc, ParsingRulesState>(
        builder: (context, state) {
          if (state is ParsingRulesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ParsingRulesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ParsingRulesBloc>().add(LoadRules());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ParsingRulesLoaded) {
            if (state.rules.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rule, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No rules yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ParsingRulesBloc>(),
                                child: const RuleEditorPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ParsingRulesBloc>().add(RefreshRules());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.rules.length,
                itemBuilder: (context, index) {
                  final rule = state.rules[index];
                  return RuleCard(
                    rule: rule,
                    onToggle: (isEnabled) {
                      context.read<ParsingRulesBloc>().add(
                        ToggleRule(ruleId: rule.id, isEnabled: isEnabled),
                      );
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ParsingRulesBloc>(),
                            child: RuleEditorPage(rule: rule),
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<ParsingRulesBloc>().add(
                        DeleteRuleRequested(ruleId: rule.id),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
  late TextEditingController _nameController;
  late TextEditingController _triggerWordsController;
  late TextEditingController _amountPatternController;
  late TextEditingController _datePatternController;
  late TextEditingController _priorityController;

  SourceType _sourceType = SourceType.sms;
  String? _categoryId;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _triggerWordsController = TextEditingController(
      text: widget.rule?.triggerWords.join(', ') ?? '',
    );
    _amountPatternController = TextEditingController(
      text: widget.rule?.amountPattern ?? '',
    );
    _datePatternController = TextEditingController(
      text: widget.rule?.datePattern ?? '',
    );
    _priorityController = TextEditingController(
      text: (widget.rule?.priority ?? 0).toString(),
    );

    if (widget.rule != null) {
      _sourceType = widget.rule!.sourceType;
      _categoryId = widget.rule!.categoryId;
      _isEnabled = widget.rule!.isEnabled;
    }
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

  ParsingRule _buildRule() {
    final now = DateTime.now();
    final triggerWords = _triggerWordsController.text
        .split(',')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    return ParsingRule(
      id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      triggerWords: triggerWords,
      amountPattern: _amountPatternController.text.trim(),
      datePattern: _datePatternController.text.trim().isEmpty
          ? null
          : _datePatternController.text.trim(),
      categoryId: _categoryId,
      sourceType: _sourceType,
      isEnabled: _isEnabled,
      priority: int.tryParse(_priorityController.text) ?? 0,
      createdAt: widget.rule?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _saveRule() async {
    if (!_formKey.currentState!.validate()) return;

    _buildRule();

    if (widget.rule == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Creating rule...')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updating rule...')));
    }

    Navigator.of(context).pop();
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Rule Name *',
                hintText: 'e.g., HDFC Bank SMS',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _triggerWordsController,
              decoration: const InputDecoration(
                labelText: 'Trigger Words *',
                hintText: 'HDFC, debit, account (comma-separated)',
                border: OutlineInputBorder(),
                helperText: 'Words that indicate this rule should be tried',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'At least one trigger word is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
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
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount pattern is required';
                }
                try {
                  RegExp(value);
                } catch (e) {
                  return 'Invalid regex pattern';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            RegexTesterWidget(
              pattern: _amountPatternController.text,
              datePattern: _datePatternController.text,
              onResult: (result) {},
            ),
            const SizedBox(height: 24),
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
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
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
              onSelectionChanged: (selection) {
                setState(() {
                  _sourceType = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _priorityController,
              decoration: const InputDecoration(
                labelText: 'Priority',
                hintText: '0',
                border: OutlineInputBorder(),
                helperText: 'Higher priority rules are tried first',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enabled'),
              subtitle: const Text('Enable this rule for parsing'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddTemplatesPage extends StatelessWidget {
  const AddTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = DefaultRulesTemplates.templates;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Template Rules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  template.sourceType == SourceType.sms
                      ? Icons.sms
                      : Icons.email,
                ),
              ),
              title: Text(template.name),
              subtitle: Text(template.description),
              trailing: ElevatedButton(
                onPressed: () {
                  template.toParsingRule();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "${template.name}"')),
                  );
                },
                child: const Text('Add'),
              ),
            ),
          );
        },
      ),
    );
  }
}
