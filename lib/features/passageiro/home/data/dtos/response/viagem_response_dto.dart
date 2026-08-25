/// Espelha o `ViagemAgendadaDto` de `GET /solicitacoes/viagens`.
class ViagemResponseDto {
  final int solicitacaoId;
  final String dataHoraPartida;
  final String? dataChegadaEstimada;
  final String origem;
  final String destino;
  final String status;
  final String tipoCorrida;
  final double valorEstimado;
  final String? motoristaNome;
  final String? placaVeiculo;

  const ViagemResponseDto({
    required this.solicitacaoId,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.status,
    required this.tipoCorrida,
    required this.valorEstimado,
    this.dataChegadaEstimada,
    this.motoristaNome,
    this.placaVeiculo,
  });

  factory ViagemResponseDto.fromJson(Map<String, dynamic> json) {
    return ViagemResponseDto(
      solicitacaoId: (json['solicitacaoId'] as num).toInt(),
      dataHoraPartida: json['dataHoraPartida'] as String,
      dataChegadaEstimada: json['dataChegadaEstimada'] as String?,
      origem: json['origem'] as String,
      destino: json['destino'] as String,
      status: json['status'] as String? ?? 'agendada',
      tipoCorrida: json['tipoCorrida'] as String? ?? '',
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble() ?? 0,
      motoristaNome: json['motoristaNome'] as String?,
      placaVeiculo: json['placaVeiculo'] as String?,
    );
  }
}
