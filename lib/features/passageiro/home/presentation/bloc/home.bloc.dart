import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/viagem.dart';
import '../../domain/usecases/buscar_viagens_por_semana_usecase.dart';
import '../utils/semana_util.dart';

abstract class PassageiroHomeEvent extends Equatable {
  const PassageiroHomeEvent();

  @override
  List<Object?> get props => [];
}

class PassageiroHomeIniciada extends PassageiroHomeEvent {
  final Usuario? usuario;

  const PassageiroHomeIniciada({this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class PassageiroHomeSemanaAnterior extends PassageiroHomeEvent {}

class PassageiroHomeSemanaProxima extends PassageiroHomeEvent {}

abstract class PassageiroHomeState extends Equatable {
  const PassageiroHomeState();

  @override
  List<Object?> get props => [];
}

class PassageiroHomeInitial extends PassageiroHomeState {}

class PassageiroHomeLoading extends PassageiroHomeState {
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const PassageiroHomeLoading({
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [inicioSemana, fimSemana, usuario];
}

class PassageiroHomeCarregada extends PassageiroHomeState {
  final List<Viagem> viagens;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const PassageiroHomeCarregada({
    required this.viagens,
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  String get intervaloSemana =>
      SemanaUtil.formatarIntervaloSemana(inicioSemana, fimSemana);

  Map<DateTime, List<Viagem>> get viagensPorDia {
    final mapa = <DateTime, List<Viagem>>{};
    for (final viagem in viagens) {
      final dia = DateTime(
        viagem.dataHoraPartida.year,
        viagem.dataHoraPartida.month,
        viagem.dataHoraPartida.day,
      );
      mapa.putIfAbsent(dia, () => []).add(viagem);
    }
    return Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  List<Object?> get props => [viagens, inicioSemana, fimSemana, usuario];
}

class PassageiroHomeErro extends PassageiroHomeState {
  final String mensagem;
  final DateTime inicioSemana;
  final DateTime fimSemana;
  final Usuario? usuario;

  const PassageiroHomeErro({
    required this.mensagem,
    required this.inicioSemana,
    required this.fimSemana,
    this.usuario,
  });

  @override
  List<Object?> get props => [mensagem, inicioSemana, fimSemana, usuario];
}

class PassageiroHomeBloc
    extends Bloc<PassageiroHomeEvent, PassageiroHomeState> {
  final PassageiroBuscarViagensPorSemanaUsecase buscarViagensPorSemanaUsecase;

  PassageiroHomeBloc({required this.buscarViagensPorSemanaUsecase})
      : super(PassageiroHomeInitial()) {
    on<PassageiroHomeIniciada>(_onIniciada);
    on<PassageiroHomeSemanaAnterior>(_onSemanaAnterior);
    on<PassageiroHomeSemanaProxima>(_onSemanaProxima);
  }

  Future<void> _onIniciada(
    PassageiroHomeIniciada event,
    Emitter<PassageiroHomeState> emit,
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
    PassageiroHomeSemanaAnterior event,
    Emitter<PassageiroHomeState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! PassageiroHomeCarregada) return;

    final inicioSemana =
        estadoAtual.inicioSemana.subtract(const Duration(days: 7));
    final fimSemana = SemanaUtil.fimSemanaUtil(inicioSemana);
    await _carregarViagens(
      emit,
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: estadoAtual.usuario,
    );
  }

  Future<void> _onSemanaProxima(
    PassageiroHomeSemanaProxima event,
    Emitter<PassageiroHomeState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! PassageiroHomeCarregada) return;

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
    Emitter<PassageiroHomeState> emit, {
    required DateTime inicioSemana,
    required DateTime fimSemana,
    Usuario? usuario,
  }) async {
    emit(PassageiroHomeLoading(
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
      usuario: usuario,
    ));

    try {
      final viagens = await buscarViagensPorSemanaUsecase(
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
      );
      emit(PassageiroHomeCarregada(
        viagens: viagens,
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ));
    } on Failure catch (e) {
      emit(PassageiroHomeErro(
        mensagem: e.message,
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ));
    } catch (e) {
      emit(PassageiroHomeErro(
        mensagem: e.toString().replaceAll('Exception: ', ''),
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
        usuario: usuario,
      ));
    }
  }
}
