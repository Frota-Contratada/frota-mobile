class ConfirmarPinResponseDto {
  final String token;
  final String tipoToken;
  final DateTime expirationDate;

  const ConfirmarPinResponseDto({
    required this.token,
    required this.tipoToken,
    required this.expirationDate,
  });

  factory ConfirmarPinResponseDto.fromJson(
    Map<String, dynamic> json, {
    String? tipoTokenFallback,
  }) {
    final validadeRaw = json['validade'] ?? json['expirationDate'];
    final tipoTokenRaw = json['tipoToken'] as String?;

    return ConfirmarPinResponseDto(
      token: json['token'] as String,
      tipoToken: tipoTokenRaw ?? tipoTokenFallback ?? 'SIGN_UP',
      expirationDate: validadeRaw != null
          ? DateTime.parse(validadeRaw as String)
          : DateTime.now().add(const Duration(minutes: 15)),
    );
  }
}
