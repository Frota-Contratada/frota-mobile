class QuantidadeNotificacoesResponseDto {
  final int quantidade;

  const QuantidadeNotificacoesResponseDto({required this.quantidade});

  factory QuantidadeNotificacoesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final response = json['response'];
    if (response is! Map) {
      throw const FormatException('Resposta da quantidade inválida.');
    }

    final quantidade = response['quantidade'];
    if (quantidade is! num) {
      throw const FormatException('Quantidade de notificações inválida.');
    }

    return QuantidadeNotificacoesResponseDto(quantidade: quantidade.toInt());
  }
}
