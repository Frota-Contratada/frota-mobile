import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/motorista_perfil.dart';
import '../../domain/usecases/buscar_motorista_perfil_usecase.dart';

abstract class MotoristaPerfilEvent extends Equatable {
  const MotoristaPerfilEvent();

  @override
  List<Object?> get props => [];
}

class MotoristaPerfilCarregado extends MotoristaPerfilEvent {
  const MotoristaPerfilCarregado();
}

abstract class MotoristaPerfilState extends Equatable {
  const MotoristaPerfilState();

  @override
  List<Object?> get props => [];
}

class MotoristaPerfilInitial extends MotoristaPerfilState {}

class MotoristaPerfilLoading extends MotoristaPerfilState {}

class MotoristaPerfilCarregada extends MotoristaPerfilState {
  final MotoristaPerfil perfil;

  const MotoristaPerfilCarregada(this.perfil);

  @override
  List<Object?> get props => [perfil];
}

class MotoristaPerfilErro extends MotoristaPerfilState {
  final String mensagem;
  final bool semConexao;

  const MotoristaPerfilErro(this.mensagem, {this.semConexao = false});

  @override
  List<Object?> get props => [mensagem, semConexao];
}

class MotoristaPerfilBloc
    extends Bloc<MotoristaPerfilEvent, MotoristaPerfilState> {
  final BuscarMotoristaPerfilUsecase buscarMotoristaPerfilUsecase;

  MotoristaPerfilBloc({required this.buscarMotoristaPerfilUsecase})
    : super(MotoristaPerfilInitial()) {
    on<MotoristaPerfilCarregado>(_onCarregado);
  }

  Future<void> _onCarregado(
    MotoristaPerfilCarregado event,
    Emitter<MotoristaPerfilState> emit,
  ) async {
    emit(MotoristaPerfilLoading());

    try {
      emit(MotoristaPerfilCarregada(await buscarMotoristaPerfilUsecase()));
    } on Failure catch (e) {
      emit(MotoristaPerfilErro(e.message, semConexao: e is NetworkFailure));
    }
  }
}
