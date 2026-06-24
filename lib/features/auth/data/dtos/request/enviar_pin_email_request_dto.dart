class EnviarPinEmailRequestDto {
  final String tipoToken;
  final String email;

  const EnviarPinEmailRequestDto({
    required this.tipoToken,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipoToken': tipoToken,
      'email': email,
    };
  }
}
