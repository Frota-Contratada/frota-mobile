import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/corrida.dart';
import '../../domain/usecases/buscar_viagens_por_semana_usecase.dart';
import '../utils/semana_util.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeIniciada extends HomeEvent {
  final Usuario? usuario;

  const HomeIniciada({this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class HomeSemanaAnterior extends HomeEvent {}

class HomeSemanaProxima extends HomeEvent {}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const HomeLoading({
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [inicioSemana, fimSemana, usuario];
}

class HomeCarregada extends HomeState {
  final List<Corrida> corridas;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const HomeCarregada({
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

class HomeErro extends HomeState {
  final String mensagem;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const HomeErro({
    required this.mensagem,
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [mensagem, inicioSemana, fimSemana, usuario];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BuscarViagensPorSemanaUsecase buscarViagensPorSemanaUsecase;

  HomeBloc({required this.buscarViagensPorSemanaUsecase})
    : super(HomeInitial()) {
    on<HomeIniciada>(_onIniciada);
    on<HomeSemanaAnterior>(_onSemanaAnterior);
    on<HomeSemanaProxima>(_onSemanaProxima);
  }

  Future<void> _onIniciada(HomeIniciada event, Emitter<HomeState> emit) async {
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
    HomeSemanaAnterior event,
    Emitter<HomeState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! HomeCarregada) return;

    final inicioSemana = estadoAtual.inicioSemana.subtract(
      const Duration(days: 7),
    );
    final fimSemana = SemanaUtil.fimSemanaUtil(inicioSemana);
    await _carregarViagens(
      emit,
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: estadoAtual.usuario,
    );
  }

  Future<void> _onSemanaProxima(
    HomeSemanaProxima event,
    Emitter<HomeState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! HomeCarregada) return;

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
    Emitter<HomeState> emit, {
    required DateTime inicioSemana,
    required DateTime fimSemana,
    Usuario? usuario,
  }) async {
    emit(
      HomeLoading(
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ),
    );

    try {
      final corridas = await buscarViagensPorSemanaUsecase(
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
      );
      emit(
        HomeCarregada(
          corridas: corridas,
          inicioSemana: inicioSemana,
          fimSemana: fimSemana,
          usuario: usuario,
        ),
      );
    } on Failure catch (e) {
      emit(
        HomeErro(
          mensagem: e.message,
          inicioSemana: inicioSemana,
          fimSemana: fimSemana,
          usuario: usuario,
        ),
      );
    } catch (e) {
      emit(
        HomeErro(
          mensagem: e.toString().replaceAll('Exception: ', ''),
          inicioSemana: inicioSemana,
          fimSemana: fimSemana,
          usuario: usuario,
        ),
      );
    }
  }
}
