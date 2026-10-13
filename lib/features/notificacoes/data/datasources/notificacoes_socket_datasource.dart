import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/services/auth_token_service.dart';
import '../../domain/entities/notificacao.dart';
import '../dtos/response/notificacao_response_dto.dart';
import '../mappers/notificacoes_mapper.dart';

typedef NotificacoesSocketFactory =
    io.Socket Function(String url, Map<String, dynamic> options);

abstract class NotificacoesSocketDatasource {
  Stream<Notificacao> get notificacoesCriadas;
  Stream<String> get notificacoesRemovidas;
  Future<void> conectar();
  Future<void> desconectar();
}

class NotificacoesSocketDatasourceImpl implements NotificacoesSocketDatasource {
  final String notificacoesBaseUrl;
  final AuthLocalDatasource authLocalDatasource;
  final AuthTokenProvider? authTokenProvider;
  final NotificacoesSocketFactory _socketFactory;
  final _criadas = StreamController<Notificacao>.broadcast();
  final _removidas = StreamController<String>.broadcast();
  io.Socket? _socket;
  Timer? _reconexaoTimer;
  bool _deveReconectar = false;
  bool _reconectando = false;
  int _geracaoConexao = 0;

  NotificacoesSocketDatasourceImpl({
    required this.notificacoesBaseUrl,
    required this.authLocalDatasource,
    this.authTokenProvider,
    NotificacoesSocketFactory? socketFactory,
  }) : _socketFactory =
           socketFactory ?? ((url, options) => io.io(url, options));

  @override
  Stream<Notificacao> get notificacoesCriadas => _criadas.stream;

  @override
  Stream<String> get notificacoesRemovidas => _removidas.stream;

  @override
  Future<void> conectar() async {
    await desconectar();
    _deveReconectar = true;
    final geracao = _geracaoConexao;
    await _criarSocket(geracao);
  }

  Future<void> _criarSocket(int geracao) async {
    final headers = await _obterHeadersAtuais();
    if (!_deveReconectar || geracao != _geracaoConexao) return;

    final socket = _socketFactory(
      notificacoesBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(headers)
          .enableForceNew()
          .disableAutoConnect()
          .disableReconnection()
          .build(),
    );
    _socket = socket;
    socket.on('notificacao.criada', processarNotificacaoCriada);
    socket.on('notificacao.removida', processarNotificacaoRemovida);
    socket.onDisconnect((_) => _agendarReconexao());
    socket.onConnectError((_) => _agendarReconexao());
    socket.onError((_) => _agendarReconexao());
    socket.connect();
  }

  Future<Map<String, String>> _obterHeadersAtuais() async {
    final token = authTokenProvider == null
        ? await authLocalDatasource.getAuthToken()
        : await authTokenProvider!.obterTokenValido();
    if (token == null || token.accessToken.isEmpty) return {};
    return {'Authorization': 'Bearer ${token.accessToken}'};
  }

  void _agendarReconexao() {
    if (!_deveReconectar || _reconectando || _reconexaoTimer != null) return;
    _reconexaoTimer = Timer(const Duration(seconds: 1), () async {
      _reconexaoTimer = null;
      if (!_deveReconectar) return;
      _reconectando = true;
      final geracao = _geracaoConexao;
      try {
        await _descartarSocketAtual();
        await _criarSocket(geracao);
      } finally {
        _reconectando = false;
      }
    });
  }

  void processarNotificacaoCriada(Object? data) {
    if (data is! Map) return;
    try {
      final json = Map<String, dynamic>.from(data);
      if (json['schemaVersion'] != 1 || json['notificacao'] is! Map) return;
      final notificacao = NotificacoesMapper.toEntity(
        NotificacaoResponseDto.fromJson(
          Map<String, dynamic>.from(json['notificacao'] as Map),
        ),
      );
      _criadas.add(notificacao);
    } on Object {
      return;
    }
  }

  void processarNotificacaoRemovida(Object? data) {
    if (data is! Map) return;
    try {
      final json = Map<String, dynamic>.from(data);
      final notificacaoId = json['notificacaoId'];
      if (json['schemaVersion'] == 1 &&
          notificacaoId is String &&
          notificacaoId.isNotEmpty) {
        _removidas.add(notificacaoId);
      }
    } on Object {
      return;
    }
  }

  @override
  Future<void> desconectar() async {
    _deveReconectar = false;
    _geracaoConexao++;
    _reconexaoTimer?.cancel();
    _reconexaoTimer = null;
    _reconectando = false;
    await _descartarSocketAtual();
  }

  Future<void> _descartarSocketAtual() async {
    final socket = _socket;
    _socket = null;
    if (socket == null) return;
    socket.clearListeners();
    socket.disconnect();
    socket.dispose();
  }
}
