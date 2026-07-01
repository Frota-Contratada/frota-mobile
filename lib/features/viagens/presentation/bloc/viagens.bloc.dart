import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/corrida.dart';
import '../../domain/usecases/buscar_viagens_por_semana_usecase.dart';
import '../utils/semana_util.dart';

// Events

abstract class ViagensEvent extends Equatable {
  const ViagensEvent();

  @override
  List<Object?> get props => [];
}

class ViagensIniciada extends ViagensEvent {
  final Usuario? usuario;

  const ViagensIniciada({this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class ViagensSemanaAnterior extends ViagensEvent {}

class ViagensSemanaProxima extends ViagensEvent {}

// States

abstract class ViagensState extends Equatable {
  const ViagensState();

  @override
  List<Object?> get props => [];
}

class ViagensInitial extends ViagensState {}

class ViagensLoading extends ViagensState {
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const ViagensLoading({
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [inicioSemana, fimSemana, usuario];
}

class ViagensCarregadas extends ViagensState {
  final List<Corrida> corridas;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const ViagensCarregadas({
    required this.corridas,
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  String get intervaloSemana =>
      SemanaUtil.formatarIntervaloSemana(inicioSemana, fimSemana);

  Map<DateTime, List<Corrida>> get corridasPorDia {
    final mapa = <DateTime, List<Corrida>>{};
    for (final corrida in corridas) {
      final dia = DateTime(
        corrida.dataHoraPartida.year,
        corrida.dataHoraPartida.month,
        corrida.dataHoraPartida.day,
      );
      mapa.putIfAbsent(dia, () => []).add(corrida);
    }
    return Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  List<Object?> get props => [corridas, inicioSemana, fimSemana, usuario];
}

class ViagensErro extends ViagensState {
  final String mensagem;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const ViagensErro({
    required this.mensagem,
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [mensagem, inicioSemana, fimSemana, usuario];
}

// Bloc

class ViagensBloc extends Bloc<ViagensEvent, ViagensState> {
  final BuscarViagensPorSemanaUsecase buscarViagensPorSemanaUsecase;

  ViagensBloc({required this.buscarViagensPorSemanaUsecase})
      : super(ViagensInitial()) {
    on<ViagensIniciada>(_onIniciada);
    on<ViagensSemanaAnterior>(_onSemanaAnterior);
    on<ViagensSemanaProxima>(_onSemanaProxima);
  }

  Future<void> _onIniciada(
    ViagensIniciada event,
    Emitter<ViagensState> emit,
  ) async {
    final inicioSemana = SemanaUtil.inicioSemanaAtual();
    final fimSemana = SemanaUtil.fimSemanaUtil(inicioSemana);
    await _carregarViagens(
      emit,
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: event.usuario,
    );
  }

  Future<void> _onSemanaAnterior(
    ViagensSemanaAnterior event,
    Emitter<ViagensState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! ViagensCarregadas) return;

    final inicioSemana = estadoAtual.inicioSemana.subtract(const Duration(days: 7));
    final fimSemana = SemanaUtil.fimSemanaUtil(inicioSemana);
    await _carregarViagens(
      emit,
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: estadoAtual.usuario,
    );
  }

  Future<void> _onSemanaProxima(
    ViagensSemanaProxima event,
    Emitter<ViagensState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! ViagensCarregadas) return;

    final inicioSemana = estadoAtual.inicioSemana.add(const Duration(days: 7));
    final fimSemana = SemanaUtil.fimSemanaUtil(inicioSemana);
    await _carregarViagens(
      emit,
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: estadoAtual.usuario,
    );
  }

  Future<void> _carregarViagens(
    Emitter<ViagensState> emit, {
    required DateTime inicioSemana,
    required DateTime fimSemana,
    Usuario? usuario,
  }) async {
    emit(ViagensLoading(
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: usuario,
    ));

    try {
      final corridas = await buscarViagensPorSemanaUsecase(
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
      );
      emit(ViagensCarregadas(
        corridas: corridas,
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ));
    } catch (e) {
      emit(ViagensErro(
        mensagem: e.toString().replaceAll('Exception: ', ''),
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ));
    }
  }
}
