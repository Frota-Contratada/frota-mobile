import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expirationDate,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expirationDate];
}
