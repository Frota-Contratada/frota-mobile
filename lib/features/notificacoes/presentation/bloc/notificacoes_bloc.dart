import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/notificacoes_repository.dart';
import '../../domain/usecases/buscar_notificacoes_usecase.dart';
import '../../domain/usecases/contar_notificacoes_nao_lidas_usecase.dart';
import '../../domain/usecases/marcar_notificacao_como_lida_usecase.dart';

abstract class NotificacoesEvent extends Equatable {
  const NotificacoesEvent();

  @override
  List<Object?> get props => [];
}

class NotificacoesCarregadas extends NotificacoesEvent {
  const NotificacoesCarregadas();
}

class NotificacaoCriadaRecebida extends NotificacoesEvent {
  final Notificacao notificacao;

  const NotificacaoCriadaRecebida(this.notificacao);

  @override
  List<Object?> get props => [notificacao];
}

class NotificacaoRemovidaRecebida extends NotificacoesEvent {
  final String notificacaoId;

  const NotificacaoRemovidaRecebida(this.notificacaoId);

  @override
  List<Object?> get props => [notificacaoId];
}

class NotificacaoSelecionada extends NotificacoesEvent {
  final String notificacaoId;
  final Completer<bool>? conclusao;

  const NotificacaoSelecionada(this.notificacaoId, {this.conclusao});

  @override
  List<Object?> get props => [notificacaoId];
}

abstract class NotificacoesState extends Equatable {
  const NotificacoesState();

  @override
  List<Object?> get props => [];
}

class NotificacoesInitial extends NotificacoesState {}

class NotificacoesLoading extends NotificacoesState {}

class NotificacoesCarregada extends NotificacoesState {
  final List<Notificacao> notificacoes;
  final int quantidadeNaoLidas;
  final String? mensagemErro;

  const NotificacoesCarregada({
    required this.notificacoes,
    required this.quantidadeNaoLidas,
    this.mensagemErro,
  });

  @override
  List<Object?> get props => [notificacoes, quantidadeNaoLidas, mensagemErro];
}

class NotificacoesErro extends NotificacoesState {
  final String mensagem;
  final bool semConexao;

  const NotificacoesErro(this.mensagem, {this.semConexao = false});

  @override
  List<Object?> get props => [mensagem, semConexao];
}

class NotificacoesBloc extends Bloc<NotificacoesEvent, NotificacoesState> {
  final BuscarNotificacoesUsecase buscarNotificacoesUsecase;
  final ContarNotificacoesNaoLidasUsecase contarNotificacoesNaoLidasUsecase;
  final MarcarNotificacaoComoLidaUsecase marcarNotificacaoComoLidaUsecase;
  final NotificacoesRepository repository;
  late final StreamSubscription<Notificacao> _criadasSubscription;
  late final StreamSubscription<String> _removidasSubscription;

  NotificacoesBloc({
    required this.buscarNotificacoesUsecase,
    required this.contarNotificacoesNaoLidasUsecase,
    required this.marcarNotificacaoComoLidaUsecase,
    required this.repository,
  }) : super(NotificacoesInitial()) {
    on<NotificacoesCarregadas>(_onCarregadas);
    on<NotificacaoCriadaRecebida>(_onNotificacaoCriada);
    on<NotificacaoRemovidaRecebida>(_onNotificacaoRemovida);
    on<NotificacaoSelecionada>(_onNotificacaoSelecionada);
    _criadasSubscription = repository.notificacoesCriadas.listen(
      (notificacao) => add(NotificacaoCriadaRecebida(notificacao)),
    );
    _removidasSubscription = repository.notificacoesRemovidas.listen(
      (notificacaoId) => add(NotificacaoRemovidaRecebida(notificacaoId)),
    );
  }

  Future<bool> marcarComoLida(String notificacaoId) {
    final conclusao = Completer<bool>();
    add(NotificacaoSelecionada(notificacaoId, conclusao: conclusao));
    return conclusao.future;
  }

  Future<void> _onCarregadas(
    NotificacoesCarregadas event,
    Emitter<NotificacoesState> emit,
  ) async {
    emit(NotificacoesLoading());
    try {
      final resultado = await Future.wait<Object?>([
        buscarNotificacoesUsecase(),
        contarNotificacoesNaoLidasUsecase(),
      ]);
      final notificacoes = _ordenar(resultado[0] as List<Notificacao>);
      emit(
        NotificacoesCarregada(
          notificacoes: notificacoes,
          quantidadeNaoLidas: resultado[1] as int,
        ),
      );
      try {
        await repository.conectar();
      } on Object {
        return;
      }
    } on Failure catch (e) {
      emit(NotificacoesErro(e.message, semConexao: e is NetworkFailure));
    } on Object catch (e) {
      emit(NotificacoesErro(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onNotificacaoCriada(
    NotificacaoCriadaRecebida event,
    Emitter<NotificacoesState> emit,
  ) {
    final atual = state;
    if (atual is! NotificacoesCarregada ||
        atual.notificacoes.any((item) => item.id == event.notificacao.id)) {
      return;
    }

    final notificacoes = _ordenar([...atual.notificacoes, event.notificacao]);
    emit(
      NotificacoesCarregada(
        notificacoes: notificacoes,
        quantidadeNaoLidas:
            atual.quantidadeNaoLidas + (event.notificacao.naoLida ? 1 : 0),
      ),
    );
  }

  void _onNotificacaoRemovida(
    NotificacaoRemovidaRecebida event,
    Emitter<NotificacoesState> emit,
  ) {
    final atual = state;
    if (atual is! NotificacoesCarregada) return;

    final removida = atual.notificacoes.where(
      (item) => item.id == event.notificacaoId,
    );
    if (removida.isEmpty) return;

    final item = removida.first;
    emit(
      NotificacoesCarregada(
        notificacoes: atual.notificacoes
            .where((notificacao) => notificacao.id != event.notificacaoId)
            .toList(),
        quantidadeNaoLidas: (atual.quantidadeNaoLidas - (item.naoLida ? 1 : 0))
            .clamp(0, double.infinity)
            .toInt(),
      ),
    );
  }

  Future<void> _onNotificacaoSelecionada(
    NotificacaoSelecionada event,
    Emitter<NotificacoesState> emit,
  ) async {
    final atual = state;
    if (atual is! NotificacoesCarregada) {
      event.conclusao?.complete(false);
      return;
    }

    final notificacao = atual.notificacoes.cast<Notificacao?>().firstWhere(
      (item) => item?.id == event.notificacaoId,
      orElse: () => null,
    );
    if (notificacao == null || !notificacao.naoLida) {
      event.conclusao?.complete(notificacao != null);
      return;
    }

    try {
      final atualizada = await marcarNotificacaoComoLidaUsecase(
        event.notificacaoId,
      );
      final notificacoes = atual.notificacoes
          .map((item) => item.id == atualizada.id ? atualizada : item)
          .toList();
      emit(
        NotificacoesCarregada(
          notificacoes: notificacoes,
          quantidadeNaoLidas: (atual.quantidadeNaoLidas - 1)
              .clamp(0, double.infinity)
              .toInt(),
        ),
      );
      event.conclusao?.complete(true);
    } on Failure catch (e) {
      emit(
        NotificacoesCarregada(
          notificacoes: atual.notificacoes,
          quantidadeNaoLidas: atual.quantidadeNaoLidas,
          mensagemErro: e.message,
        ),
      );
      event.conclusao?.complete(false);
    } on Object {
      emit(
        NotificacoesCarregada(
          notificacoes: atual.notificacoes,
          quantidadeNaoLidas: atual.quantidadeNaoLidas,
          mensagemErro: 'Não foi possível marcar a notificação como lida.',
        ),
      );
      event.conclusao?.complete(false);
    }
  }

  List<Notificacao> _ordenar(List<Notificacao> notificacoes) {
    return [...notificacoes]..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
  }

  @override
  Future<void> close() async {
    await _criadasSubscription.cancel();
    await _removidasSubscription.cancel();
    await repository.desconectar();
    return super.close();
  }
}
