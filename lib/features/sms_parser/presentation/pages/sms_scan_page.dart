import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../bloc/sms_scanner_bloc.dart';
import '../bloc/sms_scanner_event.dart';
import '../bloc/sms_scanner_state.dart';
import '../widgets/parsed_transaction_card.dart';
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../../expenses/domain/usecases/create_expenses_from_parsed_list.dart';

class SmsScanPage extends StatelessWidget {
  const SmsScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsScannerBloc, SmsScannerState>(
      buildWhen: (previous, current) =>
          current is SmsScannerInitial ||
          current is SmsScannerScanning ||
          current is SmsScannerScanComplete ||
          current is SmsScannerError,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state is SmsScannerScanComplete) ...[
                _buildLastScanInfo(state),
                const SizedBox(height: 16),
                _buildResultsSummary(context, state),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.refreshCcw),
                  label: const Text('Scan Again'),
                  onPressed: () {
                    context.read<SmsScannerBloc>().add(const StartScan());
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.eye),
                  label: Text('View ${state.results.length} Results'),
                  onPressed: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SmsScannerBloc>(),
                          child: const SmsScanResultsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ] else if (state is SmsScannerScanning) ...[
                _buildScanningIndicator(context, state),
              ] else if (state is SmsScannerError) ...[
                _buildError(context, state),
              ] else ...[
                _buildInitialState(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastScanInfo(SmsScannerScanComplete state) {
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(LucideIcons.calendarClock, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Last scan: ${dateFormat.format(state.lastScanTimestamp)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSummary(
    BuildContext context,
    SmsScannerScanComplete state,
  ) {
    final highConfidence = state.results
        .where((r) => r.isHighConfidence())
        .length;
    final mediumConfidence = state.results
        .where((r) => r.isMediumConfidence())
        .length;
    final lowConfidence = state.results
        .where((r) => r.isLowConfidence())
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.results.length} new expenses found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildConfidenceChip('High', highConfidence, Colors.green),
                const SizedBox(width: 8),
                _buildConfidenceChip('Medium', mediumConfidence, Colors.orange),
                const SizedBox(width: 8),
                _buildConfidenceChip('Low', lowConfidence, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildScanningIndicator(
    BuildContext context,
    SmsScannerScanning state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Scanning SMS...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state.totalMessages > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 4),
              Text('${state.processedMessages}/${state.totalMessages}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, SmsScannerError state) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Scan Error', style: Theme.of(context).textTheme.titleMedium),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<SmsScannerBloc>().add(const StartScan());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.messageSquare, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No scan performed yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to scan your SMS messages\nand automatically create expenses.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.scan),
              label: const Text('Scan SMS'),
              onPressed: () {
                context.read<SmsScannerBloc>().add(const StartScan());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SmsScanResultsPage extends StatefulWidget {
  final bool filterDuplicates;

  const SmsScanResultsPage({super.key, this.filterDuplicates = true});

  @override
  State<SmsScanResultsPage> createState() => _SmsScanResultsPageState();
}

class _SmsScanResultsPageState extends State<SmsScanResultsPage> {
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
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      final state = context.read<SmsScannerBloc>().state;
      if (state is SmsScannerScanComplete &&
          !state.hasReachedMax &&
          !state.isLoadingMore) {
        context.read<SmsScannerBloc>().add(
          LoadMoreScanResults(filterDuplicates: widget.filterDuplicates),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          BlocBuilder<SmsScannerBloc, SmsScannerState>(
            buildWhen: (previous, current) => current is SmsScannerScanComplete,
            builder: (context, state) {
              if (state is SmsScannerScanComplete) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<SmsScannerBloc>().add(SelectAll());
                      },
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<SmsScannerBloc>().add(DeselectAll());
                      },
                      child: const Text('Deselect All'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SmsScannerBloc, SmsScannerState>(
        buildWhen: (previous, current) =>
            current is SmsScannerScanComplete ||
            current is SmsScannerScanning ||
            current is SmsScannerInitial,
        builder: (context, state) {
          if (state is SmsScannerScanComplete) {
            if (state.results.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      size: 64,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No new expenses found',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try scanning again or add more parsing rules',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.results.length + (state.isLoadingMore ? 10 : 0),
              itemBuilder: (context, index) {
                // Show skeleton items at the bottom while loading more
                if (index >= state.results.length) {
                  return const TransactionCardSkeleton();
                }

                final transaction = state.results[index];
                return ParsedTransactionCard(
                  transaction: transaction,
                  isSelected: state.selectedIds.contains(transaction.sourceId),
                  onSelectionChanged: (selected) {
                    context.read<SmsScannerBloc>().add(
                      ToggleSelection(transactionId: transaction.sourceId),
                    );
                  },
                );
              },
            );
          }

          return const TransactionListSkeleton(itemCount: 10);
        },
      ),
      bottomNavigationBar: BlocBuilder<SmsScannerBloc, SmsScannerState>(
        buildWhen: (previous, current) => current is SmsScannerScanComplete,
        builder: (context, state) {
          if (state is SmsScannerScanComplete && state.selectedIds.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final selectedTransactions = state.results
                      .where((t) => state.selectedIds.contains(t.sourceId))
                      .toList();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Creating ${selectedTransactions.length} expenses...',
                      ),
                    ),
                  );

                  final createExpenses = di
                      .getIt<CreateExpensesFromParsedList>();
                  final result = await createExpenses(selectedTransactions);

                  if (context.mounted) {
                    result.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed: ${failure.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      (creationResult) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully created ${creationResult.createdCount} expenses!',
                            ),
                          ),
                        );
                        context.read<SmsScannerBloc>().add(ClearResults());
                        Navigator.of(context).pop();
                      },
                    );
                  }
                },
                child: Text('Create ${state.selectedIds.length} Selected'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
