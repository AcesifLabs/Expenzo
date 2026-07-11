import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import 'package:expense_tracker/features/ai_assistant/domain/entities/prompt_validation_result.dart';

class ValidateAiPrompt {
  const ValidateAiPrompt();

  PromptValidationResult call(String rawPrompt) {
    final normalized = _normalize(rawPrompt);

    if (normalized.isEmpty) {
      return const PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.emptyPromptRefusal,
      );
    }

    if (normalized.length > AiAssistantConstants.maxUserPromptLength) {
      return const PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.tooLongRefusal,
      );
    }

    if (_matchesBlockedPattern(normalized)) {
      return const PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.promptInjectionRefusal,
      );
    }

    if (!_containsFinanceKeyword(normalized)) {
      return const PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.outOfScopeRefusal,
      );
    }

    return PromptValidationResult.allow(normalized);
  }

  String _normalize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesBlockedPattern(String input) {
    final lower = input.toLowerCase();

    for (final pattern in AiAssistantConstants.blockedPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }

    return false;
  }

  bool _containsFinanceKeyword(String input) {
    final lower = input.toLowerCase();

    for (final keyword in AiAssistantConstants.financeKeywords) {
      if (lower.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}
