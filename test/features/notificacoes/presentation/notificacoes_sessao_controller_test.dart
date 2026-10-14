import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/config/routes.dart';
import 'package:frota_mobile/features/auth/domain/entities/usuario.dart';
import 'package:frota_mobile/features/auth/domain/enums/perfil_usuario.dart';
import 'package:frota_mobile/features/notificacoes/data/datasources/notificacoes_locais_datasource.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/preferencias_notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/toque_notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/notificacoes_dispositivo_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/notificacoes_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/preferencias_notificacao_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/buscar_preferencias_notificacao_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/marcar_notificacao_como_lida_usecase.dart';
import 'package:frota_mobile/features/notificacoes/presentation/sessao/notificacoes_sessao_controller.dart';

const _passageiro = Usuario(
  id: 1,
  nome: 'Passageiro',
  email: 'p@frota.com.br',
  perfil: PerfilUsuario.passageiro,
);

const _motorista = Usuario(
  id: 2,
  nome: 'Motorista',
  email: 'm@frota.com.br',
  perfil: PerfilUsuario.motorista,
);

const _acaoSolicitacao = AcaoNotificacao(
  rota: '/solicitacoes',
  parametros: {'solicitacaoId': '42'},
);

void main() {
  test('destino abre a solicitação só para passageiro com id válido', () {
    expect(destinoDaNotificacao(_acaoSolicitacao, _passageiro), (
      rota: AppRoutes.passageiroDetalheSolicitacao,
      argumentos: 42,
    ));
    expect(destinoDaNotificacao(_acaoSolicitacao, _motorista), (
      rota: AppRoutes.notificacoes,
      argumentos: _motorista,
    ));
    expect(destinoDaNotificacao(null, _passageiro), (
      rota: AppRoutes.notificacoes,
      argumentos: _passageiro,
    ));
  });

  test('payload da notificação local preserva id e ação', () {
    const toque = ToqueNotificacao(
      notificacaoId: 'n1',
      acao: _acaoSolicitacao,
    );

    expect(decodificarToque(codificarToque(toque)), toque);
    expect(decodificarToque('não é json'), isNull);
  });

  test('exibe cada notificação recebida uma única vez', () async {
    final contexto = _Contexto();
    await contexto.controller.iniciarSessao(_passageiro);

    contexto.notificacoes.criadas
      ..add(_notificacao('n1'))
      ..add(_notificacao('n1'))
      ..add(_notificacao('n2'));
    await Future<void>.delayed(Duration.zero);

    expect(contexto.dispositivo.exibidas, ['n1', 'n2']);
    expect(contexto.notificacoes.conectado, isTrue);
  });

  test('não exibe no celular quando o push está desligado', () async {
    final contexto = _Contexto(pushAtivo: false);
    await contexto.controller.iniciarSessao(_passageiro);
    await Future<void>.delayed(Duration.zero);

    contexto.notificacoes.criadas.add(_notificacao('n1'));
    await Future<void>.delayed(Duration.zero);
    expect(contexto.dispositivo.exibidas, isEmpty);

    contexto.preferencias.alteracoesController.add(
      PreferenciasNotificacao.padrao(),
    );
    contexto.notificacoes.criadas.add(_notificacao('n2'));
    await Future<void>.delayed(Duration.zero);
    expect(contexto.dispositivo.exibidas, ['n2']);
  });

  test('encerrar a sessão desconecta e para de exibir', () async {
    final contexto = _Contexto();
    await contexto.controller.iniciarSessao(_passageiro);
    await contexto.controller.encerrarSessao();

    contexto.notificacoes.criadas.add(_notificacao('n1'));
    await Future<void>.delayed(Duration.zero);

    expect(contexto.notificacoes.conectado, isFalse);
    expect(contexto.dispositivo.exibidas, isEmpty);
  });

  testWidgets('tocar na notificação marca como lida e navega', (tester) async {
    final contexto = _Contexto();
    final rotas = <RouteSettings>[];
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: contexto.navigatorKey,
        home: const SizedBox(),
        onGenerateRoute: (settings) {
          rotas.add(settings);
          return MaterialPageRoute(builder: (_) => const SizedBox());
        },
      ),
    );

    await tester.runAsync(() async {
      await contexto.controller.iniciarSessao(_passageiro);
      contexto.dispositivo.toquesController.add(
        const ToqueNotificacao(notificacaoId: 'n1', acao: _acaoSolicitacao),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump();

    expect(contexto.notificacoes.lidas, ['n1']);
    expect(rotas.single.name, AppRoutes.passageiroDetalheSolicitacao);
    expect(rotas.single.arguments, 42);
  });
}

Notificacao _notificacao(String id) => Notificacao(
  id: id,
  tipo: TipoNotificacao.lembreteViagem,
  titulo: 'Lembrete',
  mensagem: 'Sua viagem começa em breve.',
  criadaEm: DateTime.utc(2026, 10, 13),
  expiraEm: DateTime.utc(2026, 11, 13),
  acao: _acaoSolicitacao,
);

class _Contexto {
  final notificacoes = _FakeNotificacoesRepository();
  final dispositivo = _FakeDispositivoRepository();
  final _FakePreferenciasRepository preferencias;
  final navigatorKey = GlobalKey<NavigatorState>();
  late final NotificacoesSessaoController controller;

  _Contexto({bool pushAtivo = true})
    : preferencias = _FakePreferenciasRepository(pushAtivo) {
    controller = NotificacoesSessaoController(
      notificacoesRepository: notificacoes,
      dispositivoRepository: dispositivo,
      preferenciasRepository: preferencias,
      buscarPreferencias: BuscarPreferenciasNotificacaoUsecase(preferencias),
      marcarComoLida: MarcarNotificacaoComoLidaUsecase(notificacoes),
      navigatorKey: navigatorKey,
    );
  }
}

class _FakeNotificacoesRepository implements NotificacoesRepository {
  final criadas = StreamController<Notificacao>.broadcast();
  final lidas = <String>[];
  bool conectado = false;

  @override
  Stream<Notificacao> get notificacoesCriadas => criadas.stream;

  @override
  Stream<String> get notificacoesRemovidas => const Stream.empty();

  @override
  Future<List<Notificacao>> buscarTodas() async => [];

  @override
  Future<int> contarNaoLidas() async => 0;

  @override
  Future<Notificacao> marcarComoLida(String id) async {
    lidas.add(id);
    return _notificacao(id);
  }

  @override
  Future<void> conectar() async => conectado = true;

  @override
  Future<void> desconectar() async => conectado = false;
}

class _FakeDispositivoRepository implements NotificacoesDispositivoRepository {
  final toquesController = StreamController<ToqueNotificacao>.broadcast();
  final exibidas = <String>[];

  @override
  Stream<ToqueNotificacao> get toques => toquesController.stream;

  @override
  Future<bool> inicializar() async => true;

  @override
  Future<bool> solicitarPermissao() async => true;

  @override
  Future<void> exibir(Notificacao notificacao) async =>
      exibidas.add(notificacao.id);

  @override
  Future<ToqueNotificacao?> toqueInicial() async => null;
}

class _FakePreferenciasRepository implements PreferenciasNotificacaoRepository {
  final bool pushAtivo;
  final alteracoesController =
      StreamController<PreferenciasNotificacao>.broadcast();

  _FakePreferenciasRepository(this.pushAtivo);

  @override
  Stream<PreferenciasNotificacao> get alteracoes => alteracoesController.stream;

  @override
  Future<PreferenciasNotificacao> buscar() async =>
      PreferenciasNotificacao.padrao().comPush(pushAtivo);

  @override
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  }) => buscar();
}
