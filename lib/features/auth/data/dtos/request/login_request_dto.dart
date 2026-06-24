class LoginRequestDto {
  final String email;
  final String senha;
  final String plataforma;

  const LoginRequestDto({
    required this.email,
    required this.senha,
    required this.plataforma,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
      'plataforma': plataforma,
    };
  }
}
