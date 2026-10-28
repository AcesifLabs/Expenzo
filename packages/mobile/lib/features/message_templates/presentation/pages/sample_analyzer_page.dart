import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../bloc/sample_analyzer_bloc.dart';
import '../bloc/sample_analyzer_event.dart';
import '../bloc/sample_analyzer_state.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../widgets/manage_template_sheet.dart';
import 'template_editor_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

const Duration _undoWindowDuration = Duration(seconds: 5);
const Duration _errorWindowDuration = Duration(seconds: 5);

class SampleAnalyzerPage extends StatelessWidget {
  final MessageSource source;

  const SampleAnalyzerPage({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<SampleAnalyzerBloc>()
        ..add(LoadSamples(contactId: source.contactId, sourceId: source.id)),
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
  static const _maxBannerShare = 0.3;

  final ScrollController _scrollController = ScrollController();
  Timer? _undoTimer;
  Timer? _lastErrorTimer;

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
      context.read<SampleAnalyzerBloc>().add(
        LoadMoreSamples(
          contactId: widget.source.contactId,
          sourceId: widget.source.id,
        ),
      );
    }
  }

  void _onMessageTap(SmsMessage msg) {
    Navigator.of(context).push(
      SlidePageRoute<void>(
        builder: (_) =>
            TemplateEditorPage(source: widget.source, sampleMessage: msg),
      ),
    );
  }

  Future<void> _onTemplatedLongPress(
    SmsMessage msg,
    ExpenseTemplate template,
  ) async {
    final action = await showManageTemplateSheet(context: context);
    if (!mounted || action == null) return;

    switch (action) {
      case ManageTemplateAction.edit:
        _onEditTemplate(msg, template);
      case ManageTemplateAction.delete:
        context.read<SampleAnalyzerBloc>().add(TemplateDeleted(template));
    }
  }

  void _onEditTemplate(SmsMessage msg, ExpenseTemplate template) {
    final sampleMessage = _resolveEditSample(template, msg);
    Navigator.of(context).push(
      SlidePageRoute<void>(
        builder: (_) => TemplateEditorPage(
          source: widget.source,
          sampleMessage: sampleMessage,
          existingTemplate: template,
        ),
      ),
    );
  }

  SmsMessage _resolveEditSample(ExpenseTemplate template, SmsMessage fallback) {
    final state = context.read<SampleAnalyzerBloc>().state;
    if (state is SampleAnalyzerLoaded) {
      for (final message in state.messages) {
        if (message.body == template.sampleMessage) {
          return message;
        }
      }
    }

    return fallback;
  }

  void _showUndoSnackBar(ExpenseTemplate template) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: _undoWindowDuration,
        behavior: SnackBarBehavior.floating,
        content: Text(t.messageTemplates.deleted),
        action: SnackBarAction(
          label: t.common.undo,
          onPressed: () => _onUndoPressed(template),
        ),
      ),
    );

    _undoTimer?.cancel();
    _undoTimer = Timer(
      _undoWindowDuration,
      () => _onUndoTimerExpired(template),
    );
  }

  void _onUndoPressed(ExpenseTemplate template) {
    if (!mounted) return;
    context.read<SampleAnalyzerBloc>().add(TemplateDeletionUndone(template));
  }

  void _onUndoTimerExpired(ExpenseTemplate template) {
    if (!mounted) return;

    final state = context.read<SampleAnalyzerBloc>().state;
    if (state is SampleAnalyzerLoaded &&
        state.pendingDeletion?.id == template.id) {
      context.read<SampleAnalyzerBloc>().add(const TemplateDeletionExpired());
    }
    _undoTimer = null;
  }

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: _errorWindowDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.error,
        content: Text(message),
        action: SnackBarAction(
          label: t.messageTemplates.dismiss,
          onPressed: () => _onDismissError(),
        ),
      ),
    );

    _lastErrorTimer?.cancel();
    _lastErrorTimer = Timer(
      _errorWindowDuration,
      () => _onErrorTimerExpired(message),
    );
  }

  void _onDismissError() {
    if (!mounted) return;
    context.read<SampleAnalyzerBloc>().add(const LastErrorDismissed());
  }

  void _onErrorTimerExpired(String message) {
    if (!mounted) return;
    final state = context.read<SampleAnalyzerBloc>().state;
    if (state is SampleAnalyzerLoaded &&
        state.lastError != null &&
        state.lastError == message) {
      context.read<SampleAnalyzerBloc>().add(const LastErrorDismissed());
    }
    _lastErrorTimer = null;
  }

  PreferredSizeWidget _buildTopBar() {
    return AppPageHeader(
      leading: const AppBackButton(),
      title: t.messageTemplates.analyzer.title(
        sender: widget.source.contactName,
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Text(
        t.messageTemplates.analyzer.intro,
        style: AppTypography.bodyMedium.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    SmsMessage msg, {
    required bool isTemplated,
    ExpenseTemplate? existingTemplate,
  }) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          onTap: isTemplated ? null : () => _onMessageTap(msg),
          onLongPress: isTemplated && existingTemplate != null
              ? () => _onTemplatedLongPress(msg, existingTemplate)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(msg.date),
                  style: AppTypography.bodySmall.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  msg.body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.smd),
                Align(
                  alignment: Alignment.centerRight,
                  child: isTemplated && existingTemplate != null
                      ? _buildTemplatedChip(existingTemplate)
                      : _buildUseAsTemplateButton(msg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUseAsTemplateButton(SmsMessage msg) {
    final accent = context.palette.brand;

    return GestureDetector(
      onTap: () => _onMessageTap(msg),

      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        child: Center(
          widthFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: accent.withAlpha(0x1F),
              borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PiconsRegular.magicWand, size: 16, color: accent),
                Flexible(
                  child: Text(
                    t.messageTemplates.analyzer.useMessage,
                    style: AppTypography.bodySmall.copyWith(color: accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatedChip(ExpenseTemplate _) {
    final palette = context.palette;

    return Ink(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        border: Border.all(
          color: palette.textSecondary.withAlpha(0x40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PiconsRegular.checkCircle,
            size: 14,
            color: palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            t.messageTemplates.alreadyExists,
            style: AppTypography.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(color: context.palette.brand),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: context.palette.textSecondary),
      ),
    );
  }

  Widget _buildLoaded(SampleAnalyzerLoaded state) {
    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          t.messageTemplates.analyzer.noMessages,
          style: TextStyle(color: context.palette.textSecondary),
        ),
      );
    }

    final messageCount = state.messages.length;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: AppSpacing.md),
      itemCount: state.hasReachedMax ? messageCount : messageCount + 1,
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(color: context.palette.brand),
            ),
          );
        }

        final msg = state.messages[index];
        final existing = state.matchedTemplatesByMessageBody[msg.body];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.smd),
          child: _buildMessageCard(
            msg,
            isTemplated: existing != null,
            existingTemplate: existing,
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SampleAnalyzerBloc, SampleAnalyzerState>(
      builder: (context, state) {
        return switch (state) {
          SampleAnalyzerLoading() => _buildLoading(),
          SampleAnalyzerError(:final message) => _buildError(message),
          SampleAnalyzerLoaded() => _buildLoaded(state),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  void _onPendingDeletionChanged(BuildContext _, SampleAnalyzerState state) {
    final pendingDeletion = state is SampleAnalyzerLoaded
        ? state.pendingDeletion
        : null;
    if (pendingDeletion != null) {
      _showUndoSnackBar(pendingDeletion);
    }
  }

  void _onLastErrorChanged(BuildContext _, SampleAnalyzerState state) {
    final lastError = state is SampleAnalyzerLoaded ? state.lastError : null;
    if (lastError != null) {
      _showErrorSnackBar(lastError);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _undoTimer?.cancel();
    _undoTimer = null;
    _lastErrorTimer?.cancel();
    _lastErrorTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.bg,
      appBar: _buildTopBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SampleAnalyzerBloc, SampleAnalyzerState>(
            listenWhen: (prev, curr) =>
                curr is SampleAnalyzerLoaded &&
                curr.pendingDeletion != null &&
                (prev is! SampleAnalyzerLoaded ||
                    prev.pendingDeletion?.id != curr.pendingDeletion?.id),
            listener: _onPendingDeletionChanged,
          ),

          BlocListener<SampleAnalyzerBloc, SampleAnalyzerState>(
            listenWhen: (prev, curr) =>
                curr is SampleAnalyzerLoaded &&
                curr.lastError != null &&
                (prev is! SampleAnalyzerLoaded ||
                    prev.lastError != curr.lastError),
            listener: _onLastErrorChanged,
          ),
        ],
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.smd),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(context).height * _maxBannerShare,
                  ),
                  child: SingleChildScrollView(child: _buildInfoBanner()),
                ),
                const SizedBox(height: AppSpacing.smd),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
