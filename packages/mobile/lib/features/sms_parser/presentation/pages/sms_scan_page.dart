import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../bloc/sms_scanner_bloc.dart';
import '../bloc/sms_scanner_event.dart';
import '../bloc/sms_scanner_state.dart';
import '../widgets/parsed_transaction_card.dart';
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';

class SmsScanPage extends StatelessWidget {
  const SmsScanPage({super.key});

  void _onStartScan(BuildContext context) {
    context.read<SmsScannerBloc>().add(const StartScan());
  }

  void _onViewResults(BuildContext context, SmsScannerScanComplete _) {
    Navigator.of(context).push(
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SmsScannerBloc>(),
          child: const SmsScanResultsPage(),
        ),
      ),
    );
  }

  Widget _buildLastScanInfo(SmsScannerScanComplete state) {
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(PiconsRegular.calendarBlank, size: 20),
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
              '${state.results.length} new records found',
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
            Icon(PiconsRegular.warningCircle, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Scan Error', style: Theme.of(context).textTheme.titleMedium),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onStartScan(context),
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
            Icon(PiconsRegular.chat, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No scan performed yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to scan your SMS messages\nand automatically create records.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(PiconsRegular.listMagnifyingGlass),
              label: const Text('Scan SMS'),
              onPressed: () => _onStartScan(context),
            ),
          ],
        ),
      ),
    );
  }

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
                  icon: Icon(PiconsRegular.arrowsClockwise),
                  label: const Text('Scan Again'),
                  onPressed: () => _onStartScan(context),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(PiconsRegular.eye),
                  label: Text('View ${state.results.length} Results'),
                  onPressed: () => _onViewResults(context, state),
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

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
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

  void _onSelectAll() {
    context.read<SmsScannerBloc>().add(SelectAll());
  }

  void _onDeselectAll() {
    context.read<SmsScannerBloc>().add(DeselectAll());
  }

  void _onToggleSelection(String transactionId) {
    context.read<SmsScannerBloc>().add(
      ToggleSelection(transactionId: transactionId),
    );
  }

  void _onCreateSelected(SmsScannerScanComplete state) {
    final selectedTransactions = state.results
        .where((t) => state.selectedIds.contains(t.sourceId))
        .toList();

    context.read<SmsScannerBloc>().add(
      CreateSelectedExpenses(transactions: selectedTransactions),
    );
    Navigator.of(context).pop();
  }

  Widget _buildActionButtons(SmsScannerScanComplete _) {
    return Row(
      children: [
        TextButton(onPressed: _onSelectAll, child: const Text('Select All')),
        TextButton(
          onPressed: _onDeselectAll,
          child: const Text('Deselect All'),
        ),
      ],
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PiconsRegular.checkCircle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text('No new records found', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Try scanning again or add more parsing rules',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(_, int index, SmsScannerScanComplete state) {
    if (index >= state.results.length) {
      return const TransactionCardSkeleton();
    }

    final transaction = state.results[index];

    return ParsedTransactionCard(
      transaction: transaction,
      isSelected: state.selectedIds.contains(transaction.sourceId),
      onSelectionChanged: (_) => _onToggleSelection(transaction.sourceId),
    );
  }

  Widget _buildResultsList(SmsScannerScanComplete state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length + (state.isLoadingMore ? 10 : 0),
      itemBuilder: (context, index) => _buildResultCard(context, index, state),
    );
  }

  Widget _buildBody(SmsScannerScanComplete state) {
    if (state.results.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildResultsList(state);
  }

  Widget _buildBottomBar(SmsScannerScanComplete state) {
    if (state.selectedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _onCreateSelected(state),
        child: Text('Create ${state.selectedIds.length} Selected'),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                return _buildActionButtons(state);
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
            return _buildBody(state);
          }

          return const TransactionListSkeleton(itemCount: 10);
        },
      ),
      bottomNavigationBar: BlocBuilder<SmsScannerBloc, SmsScannerState>(
        buildWhen: (previous, current) => current is SmsScannerScanComplete,
        builder: (context, state) {
          if (state is SmsScannerScanComplete) {
            return _buildBottomBar(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
