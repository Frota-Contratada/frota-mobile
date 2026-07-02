class CorridaDetalheResponseDto {
  final String id;
  final String dataHoraPartida;
  final String origem;
  final String destino;
  final String nomePassageiro;
  final double valorEstimado;
  final bool ehProxima;
  final int? minutosRestantes;

  const CorridaDetalheResponseDto({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.nomePassageiro,
    required this.valorEstimado,
    this.ehProxima = false,
    this.minutosRestantes,
  });

  factory CorridaDetalheResponseDto.fromJson(Map<String, dynamic> json) {
    return CorridaDetalheResponseDto(
      id: json['id'] as String,
      dataHoraPartida: json['data_hora_partida'] as String,
      origem: json['origem'] as String,
      destino: json['destino'] as String,
      nomePassageiro: json['nome_passageiro'] as String,
      valorEstimado: (json['valor_estimado'] as num).toDouble(),
      ehProxima: json['eh_proxima'] as bool? ?? false,
      minutosRestantes: json['minutos_restantes'] as int?,
    );
  }
}
