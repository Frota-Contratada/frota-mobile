import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/notificacoes_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/buscar_notificacoes_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/contar_notificacoes_nao_lidas_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/marcar_notificacao_como_lida_usecase.dart';
import 'package:frota_mobile/features/notificacoes/presentation/bloc/notificacoes_bloc.dart';

void main() {
  test(
    'carrega, ordena, deduplica e remove notificações em tempo real',
    () async {
      final repository = _FakeNotificacoesRepository();
      final bloc = NotificacoesBloc(
        buscarNotificacoesUsecase: BuscarNotificacoesUsecase(repository),
        contarNotificacoesNaoLidasUsecase: ContarNotificacoesNaoLidasUsecase(
          repository,
        ),
        marcarNotificacaoComoLidaUsecase: MarcarNotificacaoComoLidaUsecase(
          repository,
        ),
        repository: repository,
      );

      bloc.add(const NotificacoesCarregadas());
      await bloc.stream.firstWhere((state) => state is NotificacoesCarregada);
      expect(
        (bloc.state as NotificacoesCarregada).notificacoes.first.id,
        'new',
      );

      repository.criadas.add(_notification('new', DateTime.utc(2026, 9, 3)));
      repository.criadas.add(_notification('third', DateTime.utc(2026, 9, 4)));
      await Future<void>.delayed(Duration.zero);
      expect(
        (bloc.state as NotificacoesCarregada).notificacoes.map(
          (item) => item.id,
        ),
        ['third', 'new', 'old'],
      );

      repository.removidas.add('third');
      await Future<void>.delayed(Duration.zero);
      expect(
        (bloc.state as NotificacoesCarregada).notificacoes.map(
          (item) => item.id,
        ),
        ['new', 'old'],
      );
      await bloc.close();
    },
  );

  test('marca como lida mantendo o contador consistente', () async {
    final repository = _FakeNotificacoesRepository();
    final bloc = NotificacoesBloc(
      buscarNotificacoesUsecase: BuscarNotificacoesUsecase(repository),
      contarNotificacoesNaoLidasUsecase: ContarNotificacoesNaoLidasUsecase(
        repository,
      ),
      marcarNotificacaoComoLidaUsecase: MarcarNotificacaoComoLidaUsecase(
        repository,
      ),
      repository: repository,
    );

    bloc.add(const NotificacoesCarregadas());
    await bloc.stream.firstWhere((state) => state is NotificacoesCarregada);
    expect(await bloc.marcarComoLida('new'), isTrue);
    final state = bloc.state as NotificacoesCarregada;
    expect(state.quantidadeNaoLidas, 1);
    expect(
      state.notificacoes.firstWhere((item) => item.id == 'new').naoLida,
      isFalse,
    );
    await bloc.close();
  });
}

Notificacao _notification(String id, DateTime criadaEm, {DateTime? lidaEm}) =>
    Notificacao(
      id: id,
      tipo: TipoNotificacao.lembreteViagem,
      titulo: id,
      mensagem: 'Mensagem',
      criadaEm: criadaEm,
      expiraEm: DateTime.utc(2026, 10, 1),
      lidaEm: lidaEm,
    );

class _FakeNotificacoesRepository implements NotificacoesRepository {
  final criadas = StreamController<Notificacao>.broadcast();
  final removidas = StreamController<String>.broadcast();

  @override
  Stream<Notificacao> get notificacoesCriadas => criadas.stream;

  @override
  Stream<String> get notificacoesRemovidas => removidas.stream;

  @override
  Future<List<Notificacao>> buscarTodas() async => [
    _notification(
      'old',
      DateTime.utc(2026, 9, 1),
      lidaEm: DateTime.utc(2026, 9, 1),
    ),
    _notification('new', DateTime.utc(2026, 9, 3)),
  ];

  @override
  Future<int> contarNaoLidas() async => 2;

  @override
  Future<Notificacao> marcarComoLida(String id) async => _notification(
    id,
    DateTime.utc(2026, 9, 3),
    lidaEm: DateTime.utc(2026, 9, 4),
  );

  @override
  Future<void> conectar() async {}

  @override
  Future<void> desconectar() async {
    await criadas.close();
    await removidas.close();
  }
}
