class EnderecoResponseDto {
  final int id;
  final String descricao;
  final String logradouro;
  final String cidade;
  final String uf;
  final double latitude;
  final double longitude;
  final String? numero;
  final String? bairro;

  const EnderecoResponseDto({
    required this.id,
    required this.descricao,
    required this.logradouro,
    required this.cidade,
    required this.uf,
    required this.latitude,
    required this.longitude,
    this.numero,
    this.bairro,
  });

  factory EnderecoResponseDto.fromJson(Map<String, dynamic> json) {
    return EnderecoResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      descricao: json['descricao'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
    );
  }
}

class CatalogoItemResponseDto {
  final int id;
  final String nome;
  final String? tipo;

  const CatalogoItemResponseDto({
    required this.id,
    required this.nome,
    this.tipo,
  });

  factory CatalogoItemResponseDto.fromJson(Map<String, dynamic> json) {
    return CatalogoItemResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      tipo: json['tipo'] as String?,
    );
  }
}

class ParadaResponseDto {
  final int ordem;
  final EnderecoResponseDto endereco;

  const ParadaResponseDto({required this.ordem, required this.endereco});

  factory ParadaResponseDto.fromJson(Map<String, dynamic> json) {
    return ParadaResponseDto(
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
      endereco: EnderecoResponseDto.fromJson(
        json['endereco'] as Map<String, dynamic>,
      ),
    );
  }
}

class RateioResponseDto {
  final int centroCustoId;
  final String? centroCustoNome;
  final String? aprovadorNome;
  final String statusAprovacao;
  final CatalogoItemResponseDto? motivoRecusa;

  const RateioResponseDto({
    required this.centroCustoId,
    required this.statusAprovacao,
    this.centroCustoNome,
    this.aprovadorNome,
    this.motivoRecusa,
  });

  factory RateioResponseDto.fromJson(Map<String, dynamic> json) {
    final motivo = json['motivoRecusa'] as Map<String, dynamic>?;

    return RateioResponseDto(
      centroCustoId: (json['centroCustoId'] as num?)?.toInt() ?? 0,
      statusAprovacao: json['statusAprovacao'] as String? ?? 'P',
      centroCustoNome: json['centroCustoNome'] as String?,
      aprovadorNome: json['aprovadorNome'] as String?,
      motivoRecusa: motivo == null
          ? null
          : CatalogoItemResponseDto.fromJson(motivo),
    );
  }
}

class PassageiroResponseDto {
  final String cpf;
  final String? nome;
  final bool solicitante;

  const PassageiroResponseDto({
    required this.cpf,
    required this.solicitante,
    this.nome,
  });

  factory PassageiroResponseDto.fromJson(Map<String, dynamic> json) {
    return PassageiroResponseDto(
      cpf: json['cpf'] as String? ?? '',
      solicitante: json['solicitante'] as bool? ?? false,
      nome: json['nome'] as String?,
    );
  }
}

class CorridaResponseDto {
  final int id;
  final String dataInicio;
  final String? dataFim;
  final String? motoristaNome;
  final String placaVeiculo;
  final double kmPercorrido;
  final double valorFinal;
  final bool emAndamento;

  const CorridaResponseDto({
    required this.id,
    required this.dataInicio,
    required this.placaVeiculo,
    required this.kmPercorrido,
    required this.valorFinal,
    required this.emAndamento,
    this.dataFim,
    this.motoristaNome,
  });

  factory CorridaResponseDto.fromJson(Map<String, dynamic> json) {
    return CorridaResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dataInicio: json['dataInicio'] as String,
      dataFim: json['dataFim'] as String?,
      motoristaNome: json['motoristaNome'] as String?,
      placaVeiculo: json['placaVeiculo'] as String? ?? '',
      kmPercorrido: (json['kmPercorrido'] as num?)?.toDouble() ?? 0,
      valorFinal: (json['valorFinal'] as num?)?.toDouble() ?? 0,
      emAndamento: json['emAndamento'] as bool? ?? false,
    );
  }
}

class SolicitacaoResponseDto {
  final int id;
  final String status;
  final String dataCriacao;
  final String dataCorrida;
  final String? dataChegadaEstimada;
  final int? duracaoEstimadaMinutos;
  final double distanciaEstimadaKm;
  final double valorEstimado;
  final CatalogoItemResponseDto tipoCorrida;
  final CatalogoItemResponseDto? tipoVeiculo;
  final String? fornecedorNome;
  final EnderecoResponseDto origem;
  final EnderecoResponseDto destino;
  final List<ParadaResponseDto> paradas;
  final CatalogoItemResponseDto motivoSolicitacao;
  final CatalogoItemResponseDto? motivoCancelamento;
  final CatalogoItemResponseDto? motivoReprovacao;
  final List<RateioResponseDto> centrosCusto;
  final List<PassageiroResponseDto> passageiros;
  final CorridaResponseDto? corrida;
  final bool emAndamento;
  final bool cancelavel;

  const SolicitacaoResponseDto({
    required this.id,
    required this.status,
    required this.dataCriacao,
    required this.dataCorrida,
    required this.distanciaEstimadaKm,
    required this.valorEstimado,
    required this.tipoCorrida,
    required this.origem,
    required this.destino,
    required this.motivoSolicitacao,
    required this.emAndamento,
    required this.cancelavel,
    this.dataChegadaEstimada,
    this.duracaoEstimadaMinutos,
    this.tipoVeiculo,
    this.fornecedorNome,
    this.paradas = const [],
    this.motivoCancelamento,
    this.motivoReprovacao,
    this.centrosCusto = const [],
    this.passageiros = const [],
    this.corrida,
  });

  factory SolicitacaoResponseDto.fromJson(Map<String, dynamic> json) {
    CatalogoItemResponseDto? item(String chave) {
      final valor = json[chave] as Map<String, dynamic>?;
      return valor == null ? null : CatalogoItemResponseDto.fromJson(valor);
    }

    List<T> lista<T>(String chave, T Function(Map<String, dynamic>) converter) {
      final valores = json[chave] as List<dynamic>? ?? const [];
      return valores
          .map((item) => converter(item as Map<String, dynamic>))
          .toList();
    }

    final corridaJson = json['corrida'] as Map<String, dynamic>?;

    return SolicitacaoResponseDto(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'P',
      dataCriacao: json['dataCriacao'] as String,
      dataCorrida: json['dataCorrida'] as String,
      dataChegadaEstimada: json['dataChegadaEstimada'] as String?,
      duracaoEstimadaMinutos: (json['duracaoEstimadaMinutos'] as num?)?.toInt(),
      distanciaEstimadaKm:
          (json['distanciaEstimadaKm'] as num?)?.toDouble() ?? 0,
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble() ?? 0,
      tipoCorrida:
          item('tipoCorrida') ?? const CatalogoItemResponseDto(id: 0, nome: ''),
      tipoVeiculo: item('tipoVeiculo'),
      fornecedorNome: json['fornecedorNome'] as String?,
      origem: EnderecoResponseDto.fromJson(
        json['origem'] as Map<String, dynamic>,
      ),
      destino: EnderecoResponseDto.fromJson(
        json['destino'] as Map<String, dynamic>,
      ),
      paradas: lista('paradas', ParadaResponseDto.fromJson),
      motivoSolicitacao:
          item('motivoSolicitacao') ??
          const CatalogoItemResponseDto(id: 0, nome: ''),
      motivoCancelamento: item('motivoCancelamento'),
      motivoReprovacao: item('motivoReprovacao'),
      centrosCusto: lista('centrosCusto', RateioResponseDto.fromJson),
      passageiros: lista('passageiros', PassageiroResponseDto.fromJson),
      corrida: corridaJson == null
          ? null
          : CorridaResponseDto.fromJson(corridaJson),
      emAndamento: json['emAndamento'] as bool? ?? false,
      cancelavel: json['cancelavel'] as bool? ?? false,
    );
  }
}
