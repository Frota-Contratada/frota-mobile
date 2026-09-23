/// Espelha o `ViagemAgendadaDto` de `GET /solicitacoes/viagens`.
class ViagemResponseDto {
  final int solicitacaoId;
  final String? corridaId;
  final String dataHoraPartida;
  final String? dataChegadaEstimada;
  final String origem;
  final String destino;
  final String status;
  final String tipoCorrida;
  final double valorEstimado;
  final String? motoristaNome;
  final String? placaVeiculo;
  final Map<String, dynamic>? tracking;

  const ViagemResponseDto({
    required this.solicitacaoId,
    this.corridaId,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.status,
    required this.tipoCorrida,
    required this.valorEstimado,
    this.dataChegadaEstimada,
    this.motoristaNome,
    this.placaVeiculo,
    this.tracking,
  });

  factory ViagemResponseDto.fromJson(Map<String, dynamic> json) {
    return ViagemResponseDto(
      solicitacaoId: (json['solicitacaoId'] as num).toInt(),
      corridaId: json['corridaId']?.toString(),
      dataHoraPartida: json['dataHoraPartida'] as String,
      dataChegadaEstimada: json['dataChegadaEstimada'] as String?,
      origem: _locationLabel(json['origem']),
      destino: _locationLabel(json['destino']),
      status: json['status'] as String? ?? 'agendada',
      tipoCorrida: json['tipoCorrida'] as String? ?? '',
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble() ?? 0,
      motoristaNome: json['motoristaNome'] as String?,
      placaVeiculo: json['placaVeiculo'] as String?,
      tracking: json['tracking'] is Map<String, dynamic>
          ? json['tracking'] as Map<String, dynamic>
          : json['route'] is Map<String, dynamic>
          ? json
          : null,
    );
  }
}

String _locationLabel(Object? value) {
  if (value is String) return value;
  if (value is Map) {
    return value['label'] as String? ??
        value['endereco'] as String? ??
        value['descricao'] as String? ??
        '';
  }
  return '';
}
