import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import '../bloc/sms_scanner_bloc.dart';
import '../bloc/sms_scanner_event.dart';
import '../bloc/sms_scanner_state.dart';
import '../widgets/parsed_transaction_card.dart';
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';

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
