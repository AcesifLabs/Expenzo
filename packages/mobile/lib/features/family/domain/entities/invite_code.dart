import 'package:equatable/equatable.dart';

class InviteCode extends Equatable {
  final String code;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [code, expiresAt];

  const InviteCode({required this.code, required this.expiresAt});

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);
}
