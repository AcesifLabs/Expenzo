import 'package:equatable/equatable.dart';

/// A code that lets a signed-in user join a Family Group (CONTEXT.md).
class InviteCode extends Equatable {
  final String code;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [code, expiresAt];

  const InviteCode({required this.code, required this.expiresAt});

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);
}
