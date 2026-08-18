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
      id: (json['id'] as num?)?.toInt().toString() ?? json['id'].toString(),
      dataHoraPartida: json['dataHoraPartida'] as String? ?? '',
      origem: json['origem'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      nomePassageiro: json['nomePassageiro'] as String? ?? '',
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble() ?? 0,
      ehProxima: json['ehProxima'] as bool? ?? false,
      minutosRestantes: (json['minutosRestantes'] as num?)?.toInt(),
    );
  }
}
