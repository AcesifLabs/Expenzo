import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chip.dart';
import '../widgets/typing_indicator.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/offline_gate.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiAssistantBloc>(),
      child: const _AiAssistantContent(),
    );
  }
}

class _AiAssistantContent extends StatefulWidget {
  const _AiAssistantContent();

  @override
  State<_AiAssistantContent> createState() => _AiAssistantContentState();
}

class _AiAssistantContentState extends State<_AiAssistantContent> {
  static List<String> get _suggestions => [
    t.aiAssistant.suggestions.topExpenses,
    t.aiAssistant.suggestions.budget,
  ];

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    context.read<AiAssistantBloc>().add(SendMessage(text.trim()));
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _listenForErrors(BuildContext context, AiAssistantState state) {
    final error = state.error;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: context.palette.expense,
          ),
        );
    }
  }

  PreferredSizeWidget _buildHeader() {
    return AppPageHeader(
      leading: const AppBackButton(),
      title: t.aiAssistant.title,
    );
  }

  Widget _buildChatArea(AiAssistantState state) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: state.messages.length + (state.isComposing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.messages.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: TypingIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.smd),
            child: ChatBubble(message: state.messages[index]),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      // Scrolls sideways at large text sizes, keeping one line.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final label in _suggestions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SuggestionChip(
                  label: label,
                  onTap: () => _sendMessage(label),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm + bottomInset),
      child: Text(
        t.aiAssistant.disclaimer,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }

  bool _isInputEnabled(AiAssistantState state) {
    final cooldownUntil = state.cooldownUntil;
    final isCoolingDown =
        cooldownUntil != null && DateTime.now().isBefore(cooldownUntil);

    return !state.isComposing && !isCoolingDown;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.bg,
      appBar: _buildHeader(),
      body: SafeArea(
        child: OfflineGate(
          child: BlocConsumer<AiAssistantBloc, AiAssistantState>(
            listener: _listenForErrors,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChatArea(state),
                    _buildSuggestionRow(),
                    ChatInput(
                      controller: _controller,
                      enabled: _isInputEnabled(state),
                      onSend: () => _sendMessage(_controller.text),
                      onSubmitted: _sendMessage,
                    ),
                    _buildDisclaimer(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
