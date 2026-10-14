import 'package:equatable/equatable.dart';
import 'notificacao.dart';

enum CategoriaNotificacao {
  lembreteViagem('LEMBRETE_VIAGEM', [TipoNotificacao.lembreteViagem]),
  corridaConfirmada('CORRIDA_CONFIRMADA', [
    TipoNotificacao.solicitacaoVirouCorrida,
  ]),
  solicitacaoEncerrada('SOLICITACAO_ENCERRADA', [
    TipoNotificacao.solicitacaoReprovada,
    TipoNotificacao.solicitacaoRecusadaFornecedor,
    TipoNotificacao.solicitacaoCancelada,
  ]),
  corridaCancelada('CORRIDA_CANCELADA', [TipoNotificacao.corridaCancelada]),
  aprovacaoPendente('APROVACAO_PENDENTE', [TipoNotificacao.solicitacaoCriada]),
  decisaoFornecedor('DECISAO_FORNECEDOR', [
    TipoNotificacao.solicitacaoAguardandoFornecedor,
  ]);

  final String codigo;
  final List<TipoNotificacao> tipos;

  const CategoriaNotificacao(this.codigo, this.tipos);

  static CategoriaNotificacao? aPartirDoCodigo(String codigo) {
    for (final categoria in values) {
      if (categoria.codigo == codigo) return categoria;
    }
    return null;
  }
}

class PreferenciasNotificacao extends Equatable {
  final bool pushAtivo;
  final Map<CategoriaNotificacao, bool> categorias;

  const PreferenciasNotificacao({
    required this.pushAtivo,
    required this.categorias,
  });

  factory PreferenciasNotificacao.padrao() => PreferenciasNotificacao(
    pushAtivo: true,
    categorias: {for (final c in CategoriaNotificacao.values) c: true},
  );

  bool ativa(CategoriaNotificacao categoria) => categorias[categoria] ?? true;

  PreferenciasNotificacao comPush(bool ativo) =>
      PreferenciasNotificacao(pushAtivo: ativo, categorias: categorias);

  PreferenciasNotificacao comCategoria(
    CategoriaNotificacao categoria,
    bool ativa,
  ) => PreferenciasNotificacao(
    pushAtivo: pushAtivo,
    categorias: {...categorias, categoria: ativa},
  );

  @override
  List<Object?> get props => [pushAtivo, categorias];
}
