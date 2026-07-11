import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chip.dart';
import '../widgets/typing_indicator.dart';

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
  static const _suggestions = ['Top expenses', "How's my budget?"];

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFF48FB1),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(PiconsRegular.robot, size: 28, color: Color(0xFFD1C4E9)),
          const SizedBox(width: 10),
          const Text(
            'AI Assistant',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF5F7FA),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, size: 24, color: Color(0xFFF5F7FA)),
          ),
        ],
      ),
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
              padding: EdgeInsets.symmetric(vertical: 8),
              child: TypingIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChatBubble(message: state.messages[index]),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _suggestions
            .map(
              (label) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SuggestionChip(
                  label: label,
                  onTap: () => _sendMessage(label),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDisclaimer() {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: 8 + bottomInset),
      child: const Text(
        'Expenzo AI provides suggestions based on your data. It is not a licensed financial advisor.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 11,
          color: Color(0x608E8E93),
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
      backgroundColor: const Color(0xFF141315),
      body: SafeArea(
        child: BlocConsumer<AiAssistantBloc, AiAssistantState>(
          listener: _listenForErrors,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
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
    );
  }
}
