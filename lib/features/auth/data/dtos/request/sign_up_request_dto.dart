class SignUpRequestDto {
  final String token;
  final String senha;

  const SignUpRequestDto({
    required this.token,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'senha': senha,
    };
  }
}
