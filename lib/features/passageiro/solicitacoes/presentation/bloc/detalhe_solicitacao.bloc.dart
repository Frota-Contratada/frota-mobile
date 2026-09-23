import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/motivo.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/usecases/buscar_motivos_cancelamento_usecase.dart';
import '../../domain/usecases/buscar_solicitacao_usecase.dart';
import '../../domain/usecases/cancelar_solicitacao_usecase.dart';

abstract class DetalheSolicitacaoEvent extends Equatable {
  const DetalheSolicitacaoEvent();

  @override
  List<Object?> get props => [];
}

class DetalheSolicitacaoCarregado extends DetalheSolicitacaoEvent {
  final int id;

  const DetalheSolicitacaoCarregado(this.id);

  @override
  List<Object?> get props => [id];
}

class DetalheSolicitacaoCancelado extends DetalheSolicitacaoEvent {
  final int motivoCancelamentoId;

  const DetalheSolicitacaoCancelado(this.motivoCancelamentoId);

  @override
  List<Object?> get props => [motivoCancelamentoId];
}

abstract class DetalheSolicitacaoState extends Equatable {
  const DetalheSolicitacaoState();

  @override
  List<Object?> get props => [];
}

class DetalheSolicitacaoInitial extends DetalheSolicitacaoState {}

class DetalheSolicitacaoLoading extends DetalheSolicitacaoState {}

class DetalheSolicitacaoCarregada extends DetalheSolicitacaoState {
  final Solicitacao solicitacao;
  final List<Motivo> motivosCancelamento;

  /// Verdadeiro enquanto o cancelamento está sendo enviado.
  final bool cancelando;

  /// Preenchido quando o cancelamento é concluído com sucesso.
  final bool cancelada;

  const DetalheSolicitacaoCarregada({
    required this.solicitacao,
    this.motivosCancelamento = const [],
    this.cancelando = false,
    this.cancelada = false,
  });

  DetalheSolicitacaoCarregada copyWith({
    Solicitacao? solicitacao,
    List<Motivo>? motivosCancelamento,
    bool? cancelando,
    bool? cancelada,
  }) {
    return DetalheSolicitacaoCarregada(
      solicitacao: solicitacao ?? this.solicitacao,
      motivosCancelamento: motivosCancelamento ?? this.motivosCancelamento,
      cancelando: cancelando ?? this.cancelando,
      cancelada: cancelada ?? this.cancelada,
    );
  }

  @override
  List<Object?> get props => [
    solicitacao,
    motivosCancelamento,
    cancelando,
    cancelada,
  ];
}

class DetalheSolicitacaoErro extends DetalheSolicitacaoState {
  final String mensagem;
  final bool semConexao;

  const DetalheSolicitacaoErro(this.mensagem, {this.semConexao = false});

  @override
  List<Object?> get props => [mensagem, semConexao];
}

class DetalheSolicitacaoBloc
    extends Bloc<DetalheSolicitacaoEvent, DetalheSolicitacaoState> {
  final BuscarSolicitacaoUsecase buscarSolicitacaoUsecase;
  final CancelarSolicitacaoUsecase cancelarSolicitacaoUsecase;
  final BuscarMotivosCancelamentoUsecase buscarMotivosCancelamentoUsecase;

  DetalheSolicitacaoBloc({
    required this.buscarSolicitacaoUsecase,
    required this.cancelarSolicitacaoUsecase,
    required this.buscarMotivosCancelamentoUsecase,
  }) : super(DetalheSolicitacaoInitial()) {
    on<DetalheSolicitacaoCarregado>(_onCarregado);
    on<DetalheSolicitacaoCancelado>(_onCancelado);
  }

  Future<void> _onCarregado(
    DetalheSolicitacaoCarregado event,
    Emitter<DetalheSolicitacaoState> emit,
  ) async {
    emit(DetalheSolicitacaoLoading());

    try {
      final solicitacao = await buscarSolicitacaoUsecase(event.id);

      // Os motivos só interessam se ainda for possível cancelar; falha aqui
      // não deve impedir a exibição do detalhe.
      var motivos = const <Motivo>[];

      if (solicitacao.cancelavel) {
        try {
          motivos = await buscarMotivosCancelamentoUsecase();
        } on Failure {
          motivos = const [];
        }
      }

      emit(
        DetalheSolicitacaoCarregada(
          solicitacao: solicitacao,
          motivosCancelamento: motivos,
        ),
      );
    } on Failure catch (e) {
      emit(DetalheSolicitacaoErro(e.message, semConexao: e is NetworkFailure));
    }
  }

  Future<void> _onCancelado(
    DetalheSolicitacaoCancelado event,
    Emitter<DetalheSolicitacaoState> emit,
  ) async {
    final estadoAtual = state;

    if (estadoAtual is! DetalheSolicitacaoCarregada) return;

    emit(estadoAtual.copyWith(cancelando: true));

    try {
      final solicitacao = await cancelarSolicitacaoUsecase(
        id: estadoAtual.solicitacao.id,
        motivoCancelamentoId: event.motivoCancelamentoId,
      );

      emit(
        estadoAtual.copyWith(
          solicitacao: solicitacao,
          cancelando: false,
          cancelada: true,
        ),
      );
    } on Failure catch (e) {
      emit(estadoAtual.copyWith(cancelando: false));
      emit(DetalheSolicitacaoErro(e.message));
    }
  }
}
