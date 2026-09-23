enum StatusSolicitacao {
  pendente('P'),
  aprovada('A'),
  reprovada('R'),
  cancelada('C');

  const StatusSolicitacao(this.codigo);

  final String codigo;

  static StatusSolicitacao aPartirDoCodigo(String codigo) {
    final normalizado = codigo.trim().toUpperCase();

    return StatusSolicitacao.values.firstWhere(
      (status) => status.codigo == normalizado,
      orElse: () => StatusSolicitacao.pendente,
    );
  }
}
