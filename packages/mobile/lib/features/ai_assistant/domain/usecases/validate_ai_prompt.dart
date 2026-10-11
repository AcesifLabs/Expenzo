import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import 'package:expense_tracker/features/ai_assistant/domain/entities/prompt_validation_result.dart';

class ValidateAiPrompt {
  const ValidateAiPrompt();

  PromptValidationResult call(String rawPrompt) {
    final normalized = _normalize(rawPrompt);

    if (normalized.isEmpty) {
      return PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.emptyPromptRefusal,
      );
    }

    if (normalized.length > AiAssistantConstants.maxUserPromptLength) {
      return PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.tooLongRefusal,
      );
    }

    if (_matchesBlockedPattern(normalized)) {
      return PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.promptInjectionRefusal,
      );
    }

    if (!_containsFinanceKeyword(normalized)) {
      return PromptValidationResult.deny(
        refusalMessage: AiAssistantConstants.outOfScopeRefusal,
      );
    }

    return PromptValidationResult.allow(normalized);
  }

  String _normalize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesBlockedPattern(String input) {
    final lower = _composeBanglaNukta(input.toLowerCase());

    for (final pattern in AiAssistantConstants.blockedPatterns) {
      if (RegExp(
        _composeBanglaNukta(pattern),
        caseSensitive: false,
      ).hasMatch(lower)) {
        return true;
      }
    }

    return false;
  }

  bool _containsFinanceKeyword(String input) {
    final lower = _composeBanglaNukta(input.toLowerCase());
    final words = lower.split(_wordSeparator);

    for (final raw in AiAssistantConstants.financeKeywords) {
      final keyword = _composeBanglaNukta(raw);
      if (_bangla.hasMatch(keyword)) {
        // Bangla adds case endings to the word (খরচের, টাকায়), so a keyword
        // must start a word rather than sit inside one.
        if (words.any((word) => word.startsWith(keyword))) return true;
      } else if (lower.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  static final _bangla = RegExp('[\u0980-\u09FF]');
  static final _wordSeparator = RegExp('[\\s,.?!।;:()\'"]+');

  /// Keyboards type য়, ড় and ঢ় either as one letter or as a letter plus
  /// nukta (়); compare them in one form.
  static String _composeBanglaNukta(String input) => input
      .replaceAll('\u09AF\u09BC', '\u09DF')
      .replaceAll('\u09A1\u09BC', '\u09DC')
      .replaceAll('\u09A2\u09BC', '\u09DD');
}
