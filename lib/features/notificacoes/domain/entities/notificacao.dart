import 'package:equatable/equatable.dart';

enum TipoNotificacao {
  lembreteViagem,
  solicitacaoCriada,
  solicitacaoAguardandoFornecedor,
  solicitacaoVirouCorrida,
  solicitacaoReprovada,
  solicitacaoRecusadaFornecedor,
  solicitacaoCancelada,
  corridaCancelada,
  desconhecido;

  static TipoNotificacao aPartirDoCodigo(String codigo) {
    return switch (codigo) {
      'LEMBRETE_VIAGEM' => TipoNotificacao.lembreteViagem,
      'SOLICITACAO_CRIADA' => TipoNotificacao.solicitacaoCriada,
      'SOLICITACAO_AGUARDANDO_FORNECEDOR' =>
        TipoNotificacao.solicitacaoAguardandoFornecedor,
      'SOLICITACAO_VIROU_CORRIDA' => TipoNotificacao.solicitacaoVirouCorrida,
      'SOLICITACAO_REPROVADA' => TipoNotificacao.solicitacaoReprovada,
      'SOLICITACAO_RECUSADA_FORNECEDOR' =>
        TipoNotificacao.solicitacaoRecusadaFornecedor,
      'SOLICITACAO_CANCELADA' => TipoNotificacao.solicitacaoCancelada,
      'CORRIDA_CANCELADA' => TipoNotificacao.corridaCancelada,
      _ => TipoNotificacao.desconhecido,
    };
  }

  String get codigo => switch (this) {
    TipoNotificacao.lembreteViagem => 'LEMBRETE_VIAGEM',
    TipoNotificacao.solicitacaoCriada => 'SOLICITACAO_CRIADA',
    TipoNotificacao.solicitacaoAguardandoFornecedor =>
      'SOLICITACAO_AGUARDANDO_FORNECEDOR',
    TipoNotificacao.solicitacaoVirouCorrida => 'SOLICITACAO_VIROU_CORRIDA',
    TipoNotificacao.solicitacaoReprovada => 'SOLICITACAO_REPROVADA',
    TipoNotificacao.solicitacaoRecusadaFornecedor =>
      'SOLICITACAO_RECUSADA_FORNECEDOR',
    TipoNotificacao.solicitacaoCancelada => 'SOLICITACAO_CANCELADA',
    TipoNotificacao.corridaCancelada => 'CORRIDA_CANCELADA',
    TipoNotificacao.desconhecido => 'DESCONHECIDO',
  };
}

class AcaoNotificacao extends Equatable {
  final String rota;
  final Map<String, String> parametros;

  const AcaoNotificacao({required this.rota, this.parametros = const {}});

  @override
  List<Object?> get props => [rota, parametros];
}

class Notificacao extends Equatable {
  final String id;
  final TipoNotificacao tipo;
  final String titulo;
  final String mensagem;
  final Map<String, dynamic> dados;
  final AcaoNotificacao? acao;
  final DateTime criadaEm;
  final DateTime expiraEm;
  final DateTime? lidaEm;

  const Notificacao({
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

  bool get naoLida => lidaEm == null;

  Notificacao copyWith({DateTime? lidaEm}) {
    return Notificacao(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensagem: mensagem,
      dados: dados,
      acao: acao,
      criadaEm: criadaEm,
      expiraEm: expiraEm,
      lidaEm: lidaEm ?? this.lidaEm,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tipo,
    titulo,
    mensagem,
    dados,
    acao,
    criadaEm,
    expiraEm,
    lidaEm,
  ];
}
