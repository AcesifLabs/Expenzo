import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSend;

  const ChatInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.onSubmitted,
    this.onSend,
  });

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  InputDecoration _decoration() {
    final defaultBorder = _border(const Color(0x408E8E93));

    return InputDecoration(
      hintText: 'Ask about your finances...',
      hintStyle: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 14,
        color: Color(0xFF8E8E93),
      ),
      filled: true,
      fillColor: const Color(0xFF1C1B1D),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: defaultBorder,
      enabledBorder: defaultBorder,
      focusedBorder: _border(const Color(0xFFD1C4E9)),
      disabledBorder: _border(const Color(0x208E8E93)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLength: AiAssistantConstants.maxUserPromptLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: Color(0xFFF5F7FA),
                ),
                decoration: _decoration(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFD1C4E9)
                    : const Color(0xFF2B292C),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Icon(
                  PiconsRegular.paperPlaneRight,
                  size: 20,
                  color: enabled
                      ? const Color(0xFF141315)
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
