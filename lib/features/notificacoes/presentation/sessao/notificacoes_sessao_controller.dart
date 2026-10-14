import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../../../config/routes.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/domain/enums/perfil_usuario.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/entities/toque_notificacao.dart';
import '../../domain/repositories/notificacoes_dispositivo_repository.dart';
import '../../domain/repositories/notificacoes_repository.dart';
import '../../domain/repositories/notificacoes_segundo_plano_repository.dart';
import '../../domain/repositories/preferencias_notificacao_repository.dart';
import '../../domain/usecases/buscar_preferencias_notificacao_usecase.dart';
import '../../domain/usecases/marcar_notificacao_como_lida_usecase.dart';

typedef DestinoNotificacao = ({String rota, Object? argumentos});

DestinoNotificacao destinoDaNotificacao(
  AcaoNotificacao? acao,
  Usuario usuario,
) {
  final solicitacaoId = int.tryParse(acao?.parametros['solicitacaoId'] ?? '');
  if (usuario.perfil == PerfilUsuario.passageiro &&
      acao?.rota == '/solicitacoes' &&
      solicitacaoId != null) {
    return (
      rota: AppRoutes.passageiroDetalheSolicitacao,
      argumentos: solicitacaoId,
    );
  }
  return (rota: AppRoutes.notificacoes, argumentos: usuario);
}

class NotificacoesSessaoController {
  final NotificacoesRepository notificacoesRepository;
  final NotificacoesDispositivoRepository dispositivoRepository;
  final PreferenciasNotificacaoRepository preferenciasRepository;
  final NotificacoesSegundoPlanoRepository segundoPlanoRepository;
  final BuscarPreferenciasNotificacaoUsecase buscarPreferencias;
  final MarcarNotificacaoComoLidaUsecase marcarComoLida;
  final GlobalKey<NavigatorState> navigatorKey;

  Usuario? _usuario;
  bool _pushAtivo = true;
  bool _exibicaoEmSegundoPlano = false;
  bool _toqueInicialConsumido = false;
  final Set<String> _exibidas = {};
  StreamSubscription<ToqueNotificacao>? _toquesSubscription;
  StreamSubscription<Notificacao>? _criadasSubscription;
  StreamSubscription<Object>? _preferenciasSubscription;

  NotificacoesSessaoController({
    required this.notificacoesRepository,
    required this.dispositivoRepository,
    required this.preferenciasRepository,
    required this.segundoPlanoRepository,
    required this.buscarPreferencias,
    required this.marcarComoLida,
    required this.navigatorKey,
  });

  bool get sessaoAtiva => _usuario != null;

  Future<void> iniciarSessao(Usuario usuario) async {
    if (_usuario == usuario) return;
    await encerrarSessao();
    _usuario = usuario;

    try {
      final disponivel = await dispositivoRepository.inicializar();
      if (disponivel) {
        _toquesSubscription ??= dispositivoRepository.toques.listen(_abrir);
        await dispositivoRepository.solicitarPermissao();
      }

      _preferenciasSubscription = preferenciasRepository.alteracoes.listen((
        preferencias,
      ) {
        _pushAtivo = preferencias.pushAtivo;
        segundoPlanoRepository.atualizarPushAtivo(preferencias.pushAtivo);
      });

      _exibicaoEmSegundoPlano = await segundoPlanoRepository.iniciar();
      if (!_exibicaoEmSegundoPlano) {
        unawaited(_carregarPreferencias());
        _criadasSubscription = notificacoesRepository.notificacoesCriadas
            .listen((notificacao) => unawaited(_exibir(notificacao)));
        await notificacoesRepository.conectar();
      }

      if (disponivel && !_toqueInicialConsumido) {
        _toqueInicialConsumido = true;
        final toque = await dispositivoRepository.toqueInicial();
        if (toque != null) await _abrir(toque);
      }
    } on Object catch (e) {
      debugPrint('Falha ao iniciar notificações da sessão: $e');
    }
  }

  Future<void> encerrarSessao() async {
    final estavaEmSegundoPlano = _exibicaoEmSegundoPlano;
    _usuario = null;
    _pushAtivo = true;
    _exibicaoEmSegundoPlano = false;
    _exibidas.clear();
    if (estavaEmSegundoPlano) await segundoPlanoRepository.parar();
    await _criadasSubscription?.cancel();
    await _preferenciasSubscription?.cancel();
    _criadasSubscription = null;
    _preferenciasSubscription = null;
    try {
      await notificacoesRepository.desconectar();
    } on Object catch (e) {
      debugPrint('Falha ao encerrar notificações da sessão: $e');
    }
  }

  Future<void> _carregarPreferencias() async {
    try {
      _pushAtivo = (await buscarPreferencias()).pushAtivo;
    } on Object {
      _pushAtivo = true;
    }
  }

  Future<void> _exibir(Notificacao notificacao) async {
    if (_usuario == null || !_pushAtivo || !_exibidas.add(notificacao.id)) {
      return;
    }
    try {
      await dispositivoRepository.exibir(notificacao);
    } on Object catch (e) {
      debugPrint('Falha ao exibir notificação no dispositivo: $e');
    }
  }

  Future<void> _abrir(ToqueNotificacao toque) async {
    final usuario = _usuario;
    if (usuario == null) return;

    final notificacaoId = toque.notificacaoId;
    if (notificacaoId != null) {
      unawaited(
        marcarComoLida(notificacaoId).then<void>((_) {}, onError: (_) {}),
      );
    }

    final destino = destinoDaNotificacao(toque.acao, usuario);
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      await navigator.pushNamed(destino.rota, arguments: destino.argumentos);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => navigatorKey.currentState?.pushNamed(
        destino.rota,
        arguments: destino.argumentos,
      ),
    );
  }
}
