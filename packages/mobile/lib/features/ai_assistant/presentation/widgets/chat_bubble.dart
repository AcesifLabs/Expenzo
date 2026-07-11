import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:picons/picons.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  Widget _buildUserBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD1C4E9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: Color(0xFF141315),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(String timeStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFD1C4E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(
              PiconsRegular.robot,
              size: 24,
              color: Color(0xFF141315),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B1D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: MarkdownBody(
                  data: message.content,
                  selectable: false,
                  shrinkWrap: true,
                  softLineBreak: true,
                  styleSheet: _assistantMarkdownStyleSheet(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  MarkdownStyleSheet _assistantMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        color: Color(0xFFF5F7FA),
        height: 1.4,
      ),
      h1: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5F7FA),
      ),
      h2: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5F7FA),
      ),
      h3: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5F7FA),
      ),
      strong: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5F7FA),
      ),
      em: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: Color(0xFFF5F7FA),
      ),
      code: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: Color(0xFFF5F7FA),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF2B292C),
        borderRadius: BorderRadius.circular(8),
      ),
      blockquote: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        color: Color(0xFFB8B3B6),
        height: 1.4,
      ),
      blockquotePadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFF2B292C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x408E8E93)),
      ),
      listBullet: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        color: Color(0xFFF5F7FA),
      ),
      a: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 13,
        color: Color(0xFFD1C4E9),
        decoration: TextDecoration.underline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    if (isUser) {
      return _buildUserBubble();
    }

    return _buildAssistantBubble(timeStr);
  }
}
