class AuthTokenDto {
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;

  const AuthTokenDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expirationDate,
  });

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expirationDate: DateTime.parse(
        (json['validade'] ?? json['expirationDate']) as String,
      ),
    );
  }
}
