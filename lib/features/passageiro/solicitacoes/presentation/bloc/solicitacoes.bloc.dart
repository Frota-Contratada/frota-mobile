import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/entities/status_solicitacao.dart';
import '../../domain/usecases/buscar_solicitacoes_usecase.dart';

abstract class SolicitacoesEvent extends Equatable {
  const SolicitacoesEvent();

  @override
  List<Object?> get props => [];
}

class SolicitacoesCarregadas extends SolicitacoesEvent {
  final StatusSolicitacao? status;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  final bool incluirAnteriores;

  /// Solicita ao backend somente corridas finalizadas ou canceladas.
  final bool apenasHistorico;

  const SolicitacoesCarregadas({
    this.status,
    this.dataInicio,
    this.dataFim,
    this.apenasHistorico = false,
    this.incluirAnteriores = true,
  });

  @override
  List<Object?> get props => [
    status,
    dataInicio,
    dataFim,
    apenasHistorico,
    incluirAnteriores,
  ];
}

abstract class SolicitacoesState extends Equatable {
  const SolicitacoesState();

  @override
  List<Object?> get props => [];
}

class SolicitacoesInitial extends SolicitacoesState {}

class SolicitacoesLoading extends SolicitacoesState {}

class SolicitacoesCarregada extends SolicitacoesState {
  final List<Solicitacao> solicitacoes;
  final StatusSolicitacao? filtro;

  const SolicitacoesCarregada({required this.solicitacoes, this.filtro});

  /// Agrupadas por status, na ordem em que a tela exibe os grupos.
  Map<StatusSolicitacao, List<Solicitacao>> get porStatus {
    final ordem = [
      StatusSolicitacao.aprovada,
      StatusSolicitacao.pendente,
      StatusSolicitacao.reprovada,
      StatusSolicitacao.cancelada,
    ];

    final mapa = <StatusSolicitacao, List<Solicitacao>>{};

    for (final status in ordem) {
      final doStatus = solicitacoes
          .where((solicitacao) => solicitacao.status == status)
          .toList();

      if (doStatus.isNotEmpty) mapa[status] = doStatus;
    }

    return mapa;
  }

  Map<DateTime, List<Solicitacao>> get porDia {
    final mapa = <DateTime, List<Solicitacao>>{};

    for (final solicitacao in solicitacoes) {
      final dia = DateTime(
        solicitacao.dataCorrida.year,
        solicitacao.dataCorrida.month,
        solicitacao.dataCorrida.day,
      );

      mapa.putIfAbsent(dia, () => []).add(solicitacao);
    }

    final entradas = mapa.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(entradas);
  }

  bool _ehTransporteDeItens(Solicitacao solicitacao) =>
      solicitacao.tipoCorrida.toLowerCase().contains('objeto');

  bool _concluida(Solicitacao solicitacao) =>
      solicitacao.corrida?.status == 'F';

  int get totalViagens => solicitacoes
      .where((s) => _concluida(s) && !_ehTransporteDeItens(s))
      .length;

  int get totalTransportes => solicitacoes
      .where((s) => _concluida(s) && _ehTransporteDeItens(s))
      .length;

  @override
  List<Object?> get props => [solicitacoes, filtro];
}

class SolicitacoesErro extends SolicitacoesState {
  final String mensagem;
  final bool semConexao;

  const SolicitacoesErro(this.mensagem, {this.semConexao = false});

  @override
  List<Object?> get props => [mensagem, semConexao];
}

class SolicitacoesBloc extends Bloc<SolicitacoesEvent, SolicitacoesState> {
  final BuscarSolicitacoesUsecase buscarSolicitacoesUsecase;

  SolicitacoesBloc({required this.buscarSolicitacoesUsecase})
    : super(SolicitacoesInitial()) {
    on<SolicitacoesCarregadas>(_onCarregadas);
  }

  Future<void> _onCarregadas(
    SolicitacoesCarregadas event,
    Emitter<SolicitacoesState> emit,
  ) async {
    emit(SolicitacoesLoading());

    try {
      final pagina = await buscarSolicitacoesUsecase(
        status: event.status,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        historico: event.apenasHistorico,
        incluirAnteriores: event.incluirAnteriores,
      );

      emit(
        SolicitacoesCarregada(solicitacoes: pagina.itens, filtro: event.status),
      );
    } on Failure catch (e) {
      emit(SolicitacoesErro(e.message, semConexao: e is NetworkFailure));
    }
  }
}
