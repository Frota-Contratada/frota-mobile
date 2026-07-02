class CorridaResponseDto {
  final String id;
  final String dataHoraPartida;
  final String origem;
  final String destino;
  final bool ehProxima;
  final int? minutosRestantes;

  const CorridaResponseDto({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    this.ehProxima = false,
    this.minutosRestantes,
  });

  factory CorridaResponseDto.fromJson(Map<String, dynamic> json) {
    return CorridaResponseDto(
      id: json['id'] as String,
      dataHoraPartida: json['data_hora_partida'] as String,
      origem: json['origem'] as String,
      destino: json['destino'] as String,
      ehProxima: json['eh_proxima'] as bool? ?? false,
      minutosRestantes: json['minutos_restantes'] as int?,
    );
  }
}
