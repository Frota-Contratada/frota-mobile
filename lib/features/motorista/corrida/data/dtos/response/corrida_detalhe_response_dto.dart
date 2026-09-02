class CorridaParadaResponseDto {
  final int ordem;
  final String endereco;
  final double latitude;
  final double longitude;

  const CorridaParadaResponseDto({
    required this.ordem,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  factory CorridaParadaResponseDto.fromJson(Map<String, dynamic> json) =>
      CorridaParadaResponseDto(
        ordem: (json['ordem'] as num?)?.toInt() ?? 0,
        endereco: _locationLabel(json['endereco']),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      );
}

class CorridaDetalheResponseDto {
  final String id;
  final String dataHoraPartida;
  final String origem;
  final String destino;
  final List<CorridaParadaResponseDto> paradas;
  final String nomePassageiro;
  final double valorEstimado;
  final bool ehProxima;
  final int? minutosRestantes;
  final String? motivoRecusa;
  final Map<String, dynamic>? tracking;

  const CorridaDetalheResponseDto({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    this.paradas = const [],
    required this.nomePassageiro,
    required this.valorEstimado,
    this.ehProxima = false,
    this.minutosRestantes,
    this.motivoRecusa,
    this.tracking,
  });

  factory CorridaDetalheResponseDto.fromJson(Map<String, dynamic> json) {
    return CorridaDetalheResponseDto(
      id: (json['id'] as num?)?.toInt().toString() ?? json['id'].toString(),
      dataHoraPartida: json['dataHoraPartida'] as String? ?? '',
      origem: _locationLabel(json['origem']),
      destino: _locationLabel(json['destino']),
      paradas: ((json['paradas'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => CorridaParadaResponseDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList()
        ..sort((a, b) => a.ordem.compareTo(b.ordem)),
      nomePassageiro: json['nomePassageiro'] as String? ?? '',
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble() ?? 0,
      ehProxima: json['ehProxima'] as bool? ?? false,
      minutosRestantes: (json['minutosRestantes'] as num?)?.toInt(),
      motivoRecusa: json['motivoRecusa'] as String?,
      tracking: _trackingPayload(json),
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

Map<String, dynamic>? _trackingPayload(Map<String, dynamic> json) {
  final tracking = json['tracking'];
  if (tracking is Map<String, dynamic>) return tracking;
  return json['route'] is Map<String, dynamic> ? json : null;
}
