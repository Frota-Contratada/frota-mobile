class MotoristaHistoricoResponseDto {
  final String id;
  final String dataHoraPartida;
  final String origem;
  final String destino;
  final String tipoCorrida;

  const MotoristaHistoricoResponseDto({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.tipoCorrida,
  });

  factory MotoristaHistoricoResponseDto.fromJson(Map<String, dynamic> json) {
    return MotoristaHistoricoResponseDto(
      id: (json['id'] as num?)?.toInt().toString() ?? json['id'].toString(),
      dataHoraPartida: json['dataHoraPartida'] as String? ?? '',
      origem: json['origem'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      tipoCorrida: json['tipoCorrida'] as String? ?? '',
    );
  }
}

class MotoristaPerfilResponseDto {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? fornecedorNome;
  final String? fotoPerfil;
  final int viagensFinalizadas;
  final int transportesDeItens;
  final List<MotoristaHistoricoResponseDto> historico;

  const MotoristaPerfilResponseDto({
    required this.id,
    required this.nome,
    required this.email,
    required this.viagensFinalizadas,
    required this.transportesDeItens,
    required this.historico,
    this.cpf,
    this.fornecedorNome,
    this.fotoPerfil,
  });

  factory MotoristaPerfilResponseDto.fromJson(Map<String, dynamic> json) {
    final historico = json['historico'] as List<dynamic>? ?? const [];

    return MotoristaPerfilResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String?,
      fornecedorNome: json['fornecedorNome'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
      viagensFinalizadas: (json['viagensFinalizadas'] as num?)?.toInt() ?? 0,
      transportesDeItens: (json['transportesDeItens'] as num?)?.toInt() ?? 0,
      historico: historico
          .whereType<Map<String, dynamic>>()
          .map(MotoristaHistoricoResponseDto.fromJson)
          .toList(),
    );
  }
}
