import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/error/failures.dart';
import 'package:frota_mobile/features/notificacoes/data/dtos/response/preferencias_notificacao_response_dto.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/preferencias_notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/preferencias_notificacao_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/atualizar_preferencia_notificacao_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/buscar_preferencias_notificacao_usecase.dart';
import 'package:frota_mobile/features/notificacoes/presentation/bloc/preferencias_notificacao_bloc.dart';

void main() {
  test('cada tipo conhecido pertence a exatamente uma categoria', () {
    final tipos = CategoriaNotificacao.values.expand((c) => c.tipos).toList();

    expect(tipos.toSet().length, tipos.length);
    expect(
      tipos.toSet(),
      TipoNotificacao.values
          .where((t) => t != TipoNotificacao.desconhecido)
          .toSet(),
    );
    expect(CategoriaNotificacao.values.map((c) => c.codigo), [
      'LEMBRETE_VIAGEM',
      'CORRIDA_CONFIRMADA',
      'SOLICITACAO_ENCERRADA',
      'CORRIDA_CANCELADA',
      'APROVACAO_PENDENTE',
      'DECISAO_FORNECEDOR',
    ]);
  });

  test(
    'DTO considera ativa a categoria ausente e rejeita formato inválido',
    () {
      final preferencias = PreferenciasNotificacaoResponseDto.fromJson({
        'pushAtivo': false,
        'categorias': {'CORRIDA_CANCELADA': false, 'DESCONHECIDA': false},
      }).toEntity();

      expect(preferencias.pushAtivo, isFalse);
      expect(
        preferencias.ativa(CategoriaNotificacao.corridaCancelada),
        isFalse,
      );
      expect(preferencias.ativa(CategoriaNotificacao.lembreteViagem), isTrue);
      expect(
        () => PreferenciasNotificacaoResponseDto.fromJson({'pushAtivo': 'S'}),
        throwsFormatException,
      );
    },
  );

  test('carrega do backend e mantém o valor salvo ao reabrir a tela', () async {
    final repository = _FakePreferenciasRepository();
    final bloc = _criarBloc(repository);

    bloc.add(const PreferenciasNotificacaoCarregadas());
    await _aguardarCarregada(bloc);
    bloc.add(
      const PreferenciaCategoriaAlterada(
        CategoriaNotificacao.lembreteViagem,
        false,
      ),
    );
    await bloc.stream.firstWhere(
      (s) => s is PreferenciasNotificacaoCarregada && s.salvando.isEmpty,
    );
    await bloc.close();

    final reaberto = _criarBloc(repository)
      ..add(const PreferenciasNotificacaoCarregadas());
    final estado = await _aguardarCarregada(reaberto);

    expect(repository.ultimaAlteracao, {
      CategoriaNotificacao.lembreteViagem: false,
    });
    expect(
      estado.preferencias.ativa(CategoriaNotificacao.lembreteViagem),
      isFalse,
    );
    await reaberto.close();
  });

  test('desfaz o toggle e informa o erro quando o salvamento falha', () async {
    final repository = _FakePreferenciasRepository()..falharAtualizacao = true;
    final bloc = _criarBloc(repository)
      ..add(const PreferenciasNotificacaoCarregadas());
    await _aguardarCarregada(bloc);

    bloc.add(const PreferenciaPushAlterada(false));
    final estado =
        await bloc.stream.firstWhere(
              (s) =>
                  s is PreferenciasNotificacaoCarregada &&
                  s.erroSalvamento != null,
            )
            as PreferenciasNotificacaoCarregada;

    expect(estado.preferencias.pushAtivo, isTrue);
    expect(estado.salvando, isEmpty);
    expect(estado.erroSalvamento!.mensagem, 'Sem servidor');
    await bloc.close();
  });

  test('exibe erro quando não consegue carregar', () async {
    final repository = _FakePreferenciasRepository()..falharBusca = true;
    final bloc = _criarBloc(repository)
      ..add(const PreferenciasNotificacaoCarregadas());

    final estado = await bloc.stream.firstWhere(
      (s) => s is PreferenciasNotificacaoErro,
    );

    expect((estado as PreferenciasNotificacaoErro).semConexao, isTrue);
    await bloc.close();
  });
}

PreferenciasNotificacaoBloc _criarBloc(PreferenciasNotificacaoRepository r) =>
    PreferenciasNotificacaoBloc(
      buscarPreferencias: BuscarPreferenciasNotificacaoUsecase(r),
      atualizarPreferencia: AtualizarPreferenciaNotificacaoUsecase(r),
    );

Future<PreferenciasNotificacaoCarregada> _aguardarCarregada(
  PreferenciasNotificacaoBloc bloc,
) async {
  if (bloc.state is PreferenciasNotificacaoCarregada) {
    return bloc.state as PreferenciasNotificacaoCarregada;
  }
  return await bloc.stream.firstWhere(
        (s) => s is PreferenciasNotificacaoCarregada,
      )
      as PreferenciasNotificacaoCarregada;
}

class _FakePreferenciasRepository implements PreferenciasNotificacaoRepository {
  PreferenciasNotificacao _salvas = PreferenciasNotificacao.padrao();
  Map<CategoriaNotificacao, bool>? ultimaAlteracao;
  bool falharAtualizacao = false;
  bool falharBusca = false;

  @override
  Stream<PreferenciasNotificacao> get alteracoes => const Stream.empty();

  @override
  Future<PreferenciasNotificacao> buscar() async {
    if (falharBusca) throw const NetworkFailure();
    return _salvas;
  }

  @override
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  }) async {
    if (falharAtualizacao) throw const ServerFailure('Sem servidor');
    ultimaAlteracao = categorias;
    if (pushAtivo != null) _salvas = _salvas.comPush(pushAtivo);
    for (final entrada in (categorias ?? {}).entries) {
      _salvas = _salvas.comCategoria(entrada.key, entrada.value);
    }
    return _salvas;
  }
}
