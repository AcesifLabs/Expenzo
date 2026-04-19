import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sample_analyzer_bloc.dart';
import '../../domain/entities/message_source.dart';
import 'template_editor_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

class SampleAnalyzerPage extends StatelessWidget {
  final MessageSource source;

  const SampleAnalyzerPage({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.getIt<SampleAnalyzerBloc>()
            ..add(LoadSamples(contactId: source.contactId)),
      child: SampleAnalyzerView(source: source),
    );
  }
}

class SampleAnalyzerView extends StatefulWidget {
  final MessageSource source;

  const SampleAnalyzerView({super.key, required this.source});

  @override
  State<SampleAnalyzerView> createState() => _SampleAnalyzerViewState();
}

class _SampleAnalyzerViewState extends State<SampleAnalyzerView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SampleAnalyzerBloc>().add(
        LoadMoreSamples(contactId: widget.source.contactId),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showMessageOptions(BuildContext context, dynamic msg) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Template'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TemplateEditorPage(
                        source: widget.source,
                        sampleMessage: msg,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _confirmDelete(context, msg);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic msg) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text(
            'Are you sure you want to delete this message from the template?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // TODO: Implement delete logic
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Samples: ${widget.source.contactName}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Text(
              'Select a message below to create an expense template. '
              'The app will learn to extract amounts from similar messages.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: BlocBuilder<SampleAnalyzerBloc, SampleAnalyzerState>(
              builder: (context, state) {
                if (state is SampleAnalyzerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SampleAnalyzerError) {
                  return Center(child: Text(state.message));
                }
                if (state is SampleAnalyzerLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('No recent messages found.'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: state.hasReachedMax
                        ? state.messages.length
                        : state.messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final msg = state.messages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onLongPress: () => _showMessageOptions(context, msg),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TemplateEditorPage(
                                    source: widget.source,
                                    sampleMessage: msg,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy - hh:mm a',
                                    ).format(msg.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    msg.body,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.auto_fix_high),
                                      label: const Text('Use as Template'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => TemplateEditorPage(
                                              source: widget.source,
                                              sampleMessage: msg,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
