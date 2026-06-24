enum TipoToken {
  signUp('SIGN_UP'),
  redefinirSenha('REDEFINIR_SENHA');

  const TipoToken(this.value);

  final String value;

  static TipoToken fromValue(String value) {
    return TipoToken.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoToken.signUp,
    );
  }
}
