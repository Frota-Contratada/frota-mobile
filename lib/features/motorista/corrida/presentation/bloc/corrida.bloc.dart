import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/corrida_detalhe.dart';
import '../../domain/usecases/buscar_corrida_detalhe_usecase.dart';
import '../../domain/usecases/iniciar_corrida_usecase.dart';

abstract class CorridaEvent extends Equatable {
  const CorridaEvent();

  @override
  List<Object?> get props => [];
}

class CorridaDetalheSolicitado extends CorridaEvent {
  final String corridaId;

  const CorridaDetalheSolicitado({required this.corridaId});

  @override
  List<Object?> get props => [corridaId];
}

class CorridaIniciarSolicitado extends CorridaEvent {
  final String corridaId;

  const CorridaIniciarSolicitado({required this.corridaId});

  @override
  List<Object?> get props => [corridaId];
}

abstract class CorridaState extends Equatable {
  const CorridaState();

  @override
  List<Object?> get props => [];
}

class CorridaInitial extends CorridaState {}

class CorridaLoading extends CorridaState {}

class CorridaDetalheCarregado extends CorridaState {
  final CorridaDetalhe corrida;

  const CorridaDetalheCarregado({required this.corrida});

  @override
  List<Object?> get props => [corrida];
}

class CorridaIniciando extends CorridaState {
  final CorridaDetalhe corrida;

  const CorridaIniciando({required this.corrida});

  @override
  List<Object?> get props => [corrida];
}

class CorridaIniciada extends CorridaState {
  final CorridaDetalhe corrida;

  const CorridaIniciada({required this.corrida});

  @override
  List<Object?> get props => [corrida];
}

class CorridaErro extends CorridaState {
  final String mensagem;
  final CorridaDetalhe? corrida;

  const CorridaErro({required this.mensagem, this.corrida});

  @override
  List<Object?> get props => [mensagem, corrida];
}

class CorridaBloc extends Bloc<CorridaEvent, CorridaState> {
  final BuscarCorridaDetalheUsecase buscarCorridaDetalheUsecase;
  final IniciarCorridaUsecase iniciarCorridaUsecase;

  CorridaBloc({
    required this.buscarCorridaDetalheUsecase,
    required this.iniciarCorridaUsecase,
  }) : super(CorridaInitial()) {
    on<CorridaDetalheSolicitado>(_onDetalheSolicitado);
    on<CorridaIniciarSolicitado>(_onIniciarSolicitado);
  }

  Future<void> _onDetalheSolicitado(
    CorridaDetalheSolicitado event,
    Emitter<CorridaState> emit,
  ) async {
    emit(CorridaLoading());

    try {
      final corrida = await buscarCorridaDetalheUsecase(event.corridaId);
      emit(CorridaDetalheCarregado(corrida: corrida));
    } on Failure catch (e) {
      emit(CorridaErro(mensagem: e.message));
    } catch (e) {
      emit(CorridaErro(mensagem: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onIniciarSolicitado(
    CorridaIniciarSolicitado event,
    Emitter<CorridaState> emit,
  ) async {
    final corridaAtual = _resolverCorridaAtual(state);
    if (corridaAtual == null) return;

    emit(CorridaIniciando(corrida: corridaAtual));

    try {
      final corrida = await iniciarCorridaUsecase(event.corridaId);
      emit(CorridaIniciada(corrida: corrida));
    } on Failure catch (e) {
      emit(CorridaErro(mensagem: e.message, corrida: corridaAtual));
    } catch (e) {
      emit(
        CorridaErro(
          mensagem: e.toString().replaceAll('Exception: ', ''),
          corrida: corridaAtual,
        ),
      );
    }
  }

  CorridaDetalhe? _resolverCorridaAtual(CorridaState estado) {
    if (estado is CorridaDetalheCarregado) return estado.corrida;
    if (estado is CorridaErro) return estado.corrida;
    return null;
  }
}
