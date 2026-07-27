class ViagemResponseDto {
  final String id;
  final String dataHoraPartida;
  final String origem;
  final String destino;
  final String status;

  const ViagemResponseDto({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.status,
  });

  factory ViagemResponseDto.fromJson(Map<String, dynamic> json) {
    return ViagemResponseDto(
      id: json['id'] as String,
      dataHoraPartida: json['data_hora_partida'] as String,
      origem: json['origem'] as String,
      destino: json['destino'] as String,
      status: json['status'] as String? ?? 'agendada',
    );
  }
}
