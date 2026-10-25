import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../bloc/sms_scanner_bloc.dart';
import '../bloc/sms_scanner_event.dart';
import '../bloc/sms_scanner_submission_status.dart';
import '../bloc/sms_scanner_state.dart';
import '../bloc/sms_scanner_view_mode.dart';
import '../widgets/parsed_transaction_card.dart';
import '../widgets/sms_scan_sender_section.dart';
import '../widgets/sms_scan_summary_card.dart';
import '../widgets/sms_scan_toolbar.dart';
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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

  void _onDeselectAll() {
    context.read<SmsScannerBloc>().add(DeselectAll());
  }

  void _onSelectSenderGroup(String senderKey) {
    context.read<SmsScannerBloc>().add(SelectSenderGroup(senderKey: senderKey));
  }

  void _onDeselectSenderGroup(String senderKey) {
    context.read<SmsScannerBloc>().add(
      DeselectSenderGroup(senderKey: senderKey),
    );
  }

  void _onToggleViewMode(SmsScannerScanComplete state) {
    final nextMode = state.viewMode == SmsScannerViewMode.groupedBySender
        ? SmsScannerViewMode.flatList
        : SmsScannerViewMode.groupedBySender;
    context.read<SmsScannerBloc>().add(SetViewMode(viewMode: nextMode));
  }

  void _onToggleSelection(String transactionId) {
    context.read<SmsScannerBloc>().add(
      ToggleSelection(transactionId: transactionId),
    );
  }

  void _onCreateSelected(SmsScannerScanComplete state) {
    final selectedTransactions = state.results
        .where((t) => state.selectedIds.contains(t.sourceId))
        .map((t) => t.parsedTransaction)
        .toList();

    context.read<SmsScannerBloc>().add(
      CreateSelectedExpenses(transactions: selectedTransactions),
    );
  }

  void _onSubmissionStatusChanged(
    BuildContext context,
    SmsScannerScanComplete state,
  ) {
    if (state.submissionStatus == SmsScannerSubmissionStatus.success) {
      context.pop();
    }
  }

  Widget _buildEmptyResults() {
    final strings = t.smsParser.results;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PiconsRegular.checkCircle, size: 64, color: Colors.green),
          const SizedBox(height: AppSpacing.md),
          Text(
            strings.empty,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.emptyBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildResultCard(_, int index, SmsScannerScanComplete state) {
    if (index >= state.flatResults.length) {
      return const TransactionCardSkeleton();
    }

    final transaction = state.flatResults[index];

    return ParsedTransactionCard(
      transaction: transaction.parsedTransaction,
      isSelected: state.selectedIds.contains(transaction.sourceId),
      onSelectionChanged: (_) => _onToggleSelection(transaction.sourceId),
    );
  }

  Widget _buildFlatResultsList(SmsScannerScanComplete state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: state.flatResults.length + (state.isLoadingMore ? 10 : 0),
      itemBuilder: (context, index) => _buildResultCard(context, index, state),
    );
  }

  Widget _buildGroupedResults(SmsScannerScanComplete state) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      children: [
        for (final section in state.senderSections) ...[
          SmsScanSenderSection(
            section: section,
            selectedIds: state.selectedIds,
            onSelectAll: () => _onSelectSenderGroup(section.senderKey),
            onClear: () => _onDeselectSenderGroup(section.senderKey),
            onToggleSelection: _onToggleSelection,
          ),
          const SizedBox(height: AppSpacing.smd),
        ],
        if (state.isLoadingMore)
          ...List.generate(3, (_) => const TransactionCardSkeleton()),
      ],
    );
  }

  Widget _buildHeaderSection(SmsScannerScanComplete state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.smd,
        AppSpacing.md,
        0,
      ),
      child: Column(
        children: [
          SmsScanToolbar(
            viewMode: state.viewMode,
            rangeLabel: state.activeRangeLabel,
            onToggleViewMode: () => _onToggleViewMode(state),
            onClearSelection: _onDeselectAll,
          ),
          const SizedBox(height: AppSpacing.smd),
          SmsScanSummaryCard(
            rangeLabel: state.activeRangeLabel,
            matchCount: state.results.length,
            selectedCount: state.selectedIds.length,
          ),
          if (state.submissionStatus == SmsScannerSubmissionStatus.failure &&
              state.submissionErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.smd),
            Builder(
              builder: (context) {
                final colors = Theme.of(context).colorScheme;
                final errorMessage = state.submissionErrorMessage ?? '';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.smd),
                  decoration: BoxDecoration(
                    color: colors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusControl,
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    key: const Key('scan_submission_error_message'),
                    style: TextStyle(color: colors.error),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(SmsScannerScanComplete state) {
    if (state.results.isEmpty) {
      return _buildEmptyResults();
    }

    return Column(
      children: [
        // At large text sizes the header scrolls in up to a third of the
        // height, leaving the rest to the results.
        Flexible(
          child: SingleChildScrollView(child: _buildHeaderSection(state)),
        ),
        const SizedBox(height: AppSpacing.smd),
        Expanded(
          flex: 2,
          child: state.viewMode == SmsScannerViewMode.groupedBySender
              ? _buildGroupedResults(state)
              : _buildFlatResultsList(state),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SmsScannerScanComplete state) {
    if (state.selectedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ElevatedButton(
        onPressed:
            state.submissionStatus == SmsScannerSubmissionStatus.submitting
            ? null
            : () => _onCreateSelected(state),
        child: Text(t.smsParser.results.create(n: state.selectedIds.length)),
      ),
    );
  }

  bool _listenWhenSubmissionChanged(
    SmsScannerState previous,
    SmsScannerState current,
  ) {
    if (current is! SmsScannerScanComplete) return false;
    final prev = previous is SmsScannerScanComplete
        ? previous.submissionStatus
        : SmsScannerSubmissionStatus.idle;

    return prev != current.submissionStatus;
  }

  void _onSubmissionListener(BuildContext context, SmsScannerState state) {
    if (state is SmsScannerScanComplete) {
      _onSubmissionStatusChanged(context, state);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmsScannerBloc, SmsScannerState>(
      listenWhen: _listenWhenSubmissionChanged,
      listener: _onSubmissionListener,
      child: Scaffold(
        appBar: AppPageHeader(
          leading: AppBackButton(),
          title: t.smsParser.results.title,
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
      ),
    );
  }
}
