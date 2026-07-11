import 'package:equatable/equatable.dart';

class PromptValidationResult extends Equatable {
  final bool isAllowed;
  final String normalizedPrompt;
  final String? refusalMessage;

  @override
  List<Object?> get props => [isAllowed, normalizedPrompt, refusalMessage];

  const PromptValidationResult._({
    required this.isAllowed,
    required this.normalizedPrompt,
    this.refusalMessage,
  });

  const PromptValidationResult.allow(String normalizedPrompt)
    : this._(isAllowed: true, normalizedPrompt: normalizedPrompt);

  const PromptValidationResult.deny({
    required String refusalMessage,
    String normalizedPrompt = '',
  }) : this._(
         isAllowed: false,
         normalizedPrompt: normalizedPrompt,
         refusalMessage: refusalMessage,
       );
}
