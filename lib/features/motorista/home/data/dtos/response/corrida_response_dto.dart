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
      id: (json['id'] as num?)?.toInt().toString() ?? json['id'].toString(),
      dataHoraPartida: json['dataHoraPartida'] as String? ?? '',
      origem: json['origem'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      ehProxima: json['ehProxima'] as bool? ?? false,
      minutosRestantes: (json['minutosRestantes'] as num?)?.toInt(),
    );
  }
}
