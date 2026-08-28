class ConfirmarPinRequestDto {
  final String pin;
  final String email;
  final String tipoToken;

  const ConfirmarPinRequestDto({
    required this.pin,
    required this.email,
    required this.tipoToken,
  });

  Map<String, dynamic> toJson() {
    return {'pin': pin, 'email': email, 'tipoToken': tipoToken};
  }
}
