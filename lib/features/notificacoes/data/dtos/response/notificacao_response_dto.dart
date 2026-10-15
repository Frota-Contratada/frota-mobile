class AcaoNotificacaoResponseDto {
  final String rota;
  final Map<String, String> parametros;

  const AcaoNotificacaoResponseDto({
    required this.rota,
    this.parametros = const {},
  });

  factory AcaoNotificacaoResponseDto.fromJson(Map<String, dynamic> json) {
    final rota = json['rota'];
    if (rota is! String || rota.isEmpty) {
      throw const FormatException('Rota da notificação inválida.');
    }

    final parametrosJson = json['parametros'];
    if (parametrosJson != null && parametrosJson is! Map) {
      throw const FormatException('Parâmetros da notificação inválidos.');
    }

    final parametros = <String, String>{};
    if (parametrosJson is Map) {
      for (final entry in parametrosJson.entries) {
        if (entry.key is! String || entry.value is! String) {
          throw const FormatException('Parâmetros da notificação inválidos.');
        }
        parametros[entry.key as String] = entry.value as String;
      }
    }

    return AcaoNotificacaoResponseDto(rota: rota, parametros: parametros);
  }
}

class NotificacaoResponseDto {
  final String id;
  final String tipo;
  final String titulo;
  final String mensagem;
  final Map<String, dynamic> dados;
  final AcaoNotificacaoResponseDto? acao;
  final String criadaEm;
  final String expiraEm;
  final String? lidaEm;

  const NotificacaoResponseDto({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.criadaEm,
    required this.expiraEm,
    this.dados = const {},
    this.acao,
    this.lidaEm,
  });

  factory NotificacaoResponseDto.fromJson(Map<String, dynamic> json) {
    String textoObrigatorio(String chave) {
      final valor = json[chave];
      if (valor is! String || valor.isEmpty) {
        throw FormatException('Campo $chave da notificação inválido.');
      }
      return valor;
    }

    final dadosJson = json['dados'];
    if (dadosJson != null && dadosJson is! Map) {
      throw const FormatException('Dados da notificação inválidos.');
    }

    final acaoJson = json['acao'];
    if (acaoJson != null && acaoJson is! Map) {
      throw const FormatException('Ação da notificação inválida.');
    }

    final lidaEm = json['lidaEm'];
    if (lidaEm != null && lidaEm is! String) {
      throw const FormatException('Data de leitura da notificação inválida.');
    }

    return NotificacaoResponseDto(
      id: textoObrigatorio('id'),
      tipo: textoObrigatorio('tipo'),
      titulo: textoObrigatorio('titulo'),
      mensagem: textoObrigatorio('mensagem'),
      dados: dadosJson == null
          ? const {}
          : Map<String, dynamic>.from(dadosJson as Map),
      acao: acaoJson == null
          ? null
          : AcaoNotificacaoResponseDto.fromJson(
              Map<String, dynamic>.from(acaoJson as Map),
            ),
      criadaEm: textoObrigatorio('criadaEm'),
      expiraEm: textoObrigatorio('expiraEm'),
      lidaEm: lidaEm as String?,
    );
  }
}
