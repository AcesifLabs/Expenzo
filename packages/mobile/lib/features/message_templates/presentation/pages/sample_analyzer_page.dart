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
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

const Color _background = Color(0xFF141315);
const Color _surface = Color(0xFF1C1B1D);
const Color _primary = Color(0xFFD1C4E9);
const Color _primaryGlow = Color(0x1FD1C4E9);
const Color _disabledChip = Color(0xFF2C2C2E);
const Color _disabledChipBorder = Color(0xFF3A3A3C);
const Color _textPrimary = Color(0xFFF5F7FA);
const Color _textSecondary = Color(0xFF8E8E93);
const AlwaysStoppedAnimation<Color> _indicatorColor =
    AlwaysStoppedAnimation<Color>(_primary);
const TextStyle _textSecondaryStyle = TextStyle(
  color: _textSecondary,
  fontFamily: 'Work Sans',
);
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

/// Owns the transient SnackBar surface for `SampleAnalyzerPage`.
///
/// **SnackBar eviction policy:** this class intentionally maintains
/// an *asymmetric* relationship between the two SnackBar channels:
///
///   - `_showUndoSnackBar` (driven by `pendingDeletion`) is **primary**:
///     it calls `messenger.clearSnackBars()` before showing so a fresh
///     delete always replaces the prior undo SnackBar. This guarantees
///     the visible Undo action always targets the bloc's current
///     `pendingDeletion` — the bloc's single-slot model would otherwise
///     leave a "stale" Undo that silently no-ops because the
///     handler's id-equality guard fails.
///
///   - `_showErrorSnackBar` (driven by `lastError`) is **secondary**:
///     it does NOT call `clearSnackBars()` so error notifications
///     queue behind an active undo SnackBar instead of evicting it.
///     A future emit that carries both `pendingDeletion` and
///     `lastError` simultaneously will surface both, the undo on top
///     (because undo is the primary channel) and the error behind.
///
/// Do NOT flip this asymmetry without also revisiting the bloc's
/// `pendingDeletion` model — for example, if `pendingDeletion` becomes
/// a list of pending undos, both SnackBar channels can share the
/// queueing rule and the `clearSnackBars()` calls can be removed
/// from `_showUndoSnackBar` as well.
class _SampleAnalyzerViewState extends State<SampleAnalyzerView> {
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
      SlidePageRoute(
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
      SlidePageRoute(
        builder: (_) => TemplateEditorPage(
          source: widget.source,
          sampleMessage: sampleMessage,
          existingTemplate: template,
        ),
      ),
    );
  }

  /// Returns the loaded [SmsMessage] whose body matches the template's
  /// original `sampleMessage` so the editor pre-fills correctly. Falls
  /// back to [fallback] (the long-pressed message) when that original
  /// sample is not currently loaded.
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
        content: const Text('Template deleted'),
        action: SnackBarAction(
          label: 'Undo',
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
    // Clear stale pendingDeletion only if it's still this template,
    // so the bloc isn't re-entered for an already-undone or
    // already-replaced entry.
    final state = context.read<SampleAnalyzerBloc>().state;
    if (state is SampleAnalyzerLoaded &&
        state.pendingDeletion?.id == template.id) {
      context.read<SampleAnalyzerBloc>().add(const TemplateDeletionExpired());
    }
    _undoTimer = null;
  }

  void _showErrorSnackBar(String message) {
    // No `clearSnackBars()` here: the undo SnackBar (driven by
    // `pendingDeletion`) and the error SnackBar (driven by
    // `lastError`) are both transient, and queueing them is preferable
    // to evicting one with the other — e.g. when a future failure
    // emit carries both signals at once.
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: _errorWindowDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.error,
        content: Text(message),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => _onDismissError(),
        ),
      ),
    );

    // Auto-dismiss the error after the SnackBar window so `lastError`
    // does not linger in Loaded state forever. The timer is canceled
    // on dispose and on every refire (new error message) to keep
    // closure discipline. Guarded on string equality so a fresh
    // `lastError` that arrived mid-window isn't cleared by an older
    // timer.
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: _textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Samples: ${widget.source.contactName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              fontFamily: 'Work Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Select a message below to create an expense template. '
        'The app will learn to extract amounts from similar messages.',
        style: TextStyle(
          fontSize: 14,
          color: _textSecondary,
          fontFamily: 'Work Sans',
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    SmsMessage msg, {
    required bool isTemplated,
    ExpenseTemplate? existingTemplate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: const Color(0x00000000),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isTemplated ? null : () => _onMessageTap(msg),
          onLongPress: isTemplated && existingTemplate != null
              ? () => _onTemplatedLongPress(msg, existingTemplate)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(msg.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontFamily: 'Work Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  msg.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textPrimary,
                    fontFamily: 'Work Sans',
                  ),
                ),
                const SizedBox(height: 12),
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
    return GestureDetector(
      onTap: () => _onMessageTap(msg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryGlow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, size: 16, color: _primary),
            SizedBox(width: 6),
            Text(
              'Use as Template',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _primary,
                fontFamily: 'Work Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatedChip(ExpenseTemplate _) {
    // Painted via `Ink` (not an opaque `Container`) so the chip's grey fill
    // shares the card's InkWell material canvas. This lets the card's
    // long-press highlight overlay the chip too, instead of the chip's fill
    // blocking the ink. The chip has no gesture handlers of its own — the
    // parent card `InkWell` still owns the long-press.
    return Ink(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _disabledChip,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _disabledChipBorder, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PiconsRegular.checkCircle, size: 14, color: _textSecondary),
          SizedBox(width: 6),
          Text(
            'Template already exists',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              fontFamily: 'Work Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(valueColor: _indicatorColor),
    );
  }

  Widget _buildError(String message) {
    return Center(child: Text(message, style: _textSecondaryStyle));
  }

  Widget _buildLoaded(SampleAnalyzerLoaded state) {
    if (state.messages.isEmpty) {
      return const Center(
        child: Text(
          'No recent messages found.',
          style: TextStyle(color: _textSecondary, fontFamily: 'Work Sans'),
        ),
      );
    }

    final messageCount = state.messages.length;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16),
      itemCount: state.hasReachedMax ? messageCount : messageCount + 1,
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(valueColor: _indicatorColor),
            ),
          );
        }

        final msg = state.messages[index];
        final existing = state.matchedTemplatesByMessageBody[msg.body];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
      backgroundColor: _background,
      body: MultiBlocListener(
        listeners: [
          // Undo SnackBar — fires when `pendingDeletion` transitions
          // to a NEW non-null template id. Cleared on Undo/expire
          // don't refire, so duplicate deletes aren't double-shown.
          BlocListener<SampleAnalyzerBloc, SampleAnalyzerState>(
            listenWhen: (prev, curr) =>
                curr is SampleAnalyzerLoaded &&
                curr.pendingDeletion != null &&
                (prev is! SampleAnalyzerLoaded ||
                    prev.pendingDeletion?.id != curr.pendingDeletion?.id),
            listener: _onPendingDeletionChanged,
          ),
          // Transient error SnackBar — fires when `lastError`
          // transitions to a NEW non-null message; Dismiss dispatches
          // `LastErrorDismissed` to clear it so the same message
          // doesn't refire on subsequent state updates.
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(),
                const SizedBox(height: 12),
                _buildInfoBanner(),
                const SizedBox(height: 12),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
