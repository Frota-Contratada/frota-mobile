import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/maps/endereco_estruturado.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../../domain/entities/catalogos_solicitacao.dart';
import '../../domain/entities/nova_solicitacao.dart';
import '../../domain/entities/simulacao_solicitacao.dart';
import '../../domain/usecases/buscar_catalogos_usecase.dart';
import '../../domain/usecases/criar_solicitacao_usecase.dart';
import '../../domain/usecases/simular_solicitacao_usecase.dart';
import '../utils/solicitacao_formatters.dart';

class RascunhoSolicitacao {
  final String data;
  final String horario;
  final String? motivoNome;
  final String? veiculoNome;
  final List<String> centrosCusto;
  final List<String> cpfsAcompanhantes;
  final String origemDescricao;
  final MapPoint? origemPoint;
  final String destinoDescricao;
  final MapPoint? destinoPoint;
  final List<String> paradasDescricao;
  final List<MapPoint> paradaPoints;
  final bool objeto;

  const RascunhoSolicitacao({
    required this.data,
    required this.horario,
    required this.origemDescricao,
    required this.destinoDescricao,
    required this.centrosCusto,
    this.motivoNome,
    this.veiculoNome,
    this.cpfsAcompanhantes = const [],
    this.origemPoint,
    this.destinoPoint,
    this.paradasDescricao = const [],
    this.paradaPoints = const [],
    this.objeto = false,
  });
}

class SolicitacaoDraft {
  final String data;
  final String horario;
  final String? motivoNome;
  final String? veiculoNome;
  final List<String> centrosCusto;
  final List<String> cpfsAcompanhantes;
  final String origemDescricao;
  final MapPoint? origemPoint;
  final String destinoDescricao;
  final MapPoint? destinoPoint;
  final List<String> paradasDescricao;
  final List<MapPoint?> paradaPoints;
  final bool objeto;
  final bool? viagemCompartilhada;

  const SolicitacaoDraft({
    this.data = '',
    this.horario = '',
    this.motivoNome,
    this.veiculoNome,
    this.centrosCusto = const [],
    this.cpfsAcompanhantes = const [],
    this.origemDescricao = '',
    this.origemPoint,
    this.destinoDescricao = '',
    this.destinoPoint,
    this.paradasDescricao = const [],
    this.paradaPoints = const [],
    this.objeto = false,
    this.viagemCompartilhada,
  });

  SolicitacaoDraft copyWith({
    String? data,
    String? horario,
    String? motivoNome,
    String? veiculoNome,
    List<String>? centrosCusto,
    List<String>? cpfsAcompanhantes,
    String? origemDescricao,
    MapPoint? origemPoint,
    String? destinoDescricao,
    MapPoint? destinoPoint,
    List<String>? paradasDescricao,
    List<MapPoint?>? paradaPoints,
    bool? objeto,
    bool? viagemCompartilhada,
  }) {
    return SolicitacaoDraft(
      data: data ?? this.data,
      horario: horario ?? this.horario,
      motivoNome: motivoNome ?? this.motivoNome,
      veiculoNome: veiculoNome ?? this.veiculoNome,
      centrosCusto: centrosCusto ?? this.centrosCusto,
      cpfsAcompanhantes: cpfsAcompanhantes ?? this.cpfsAcompanhantes,
      origemDescricao: origemDescricao ?? this.origemDescricao,
      origemPoint: origemPoint ?? this.origemPoint,
      destinoDescricao: destinoDescricao ?? this.destinoDescricao,
      destinoPoint: destinoPoint ?? this.destinoPoint,
      paradasDescricao: paradasDescricao ?? this.paradasDescricao,
      paradaPoints: paradaPoints ?? this.paradaPoints,
      objeto: objeto ?? this.objeto,
      viagemCompartilhada: viagemCompartilhada ?? this.viagemCompartilhada,
    );
  }

  RascunhoSolicitacao toRascunho() {
    return RascunhoSolicitacao(
      data: data,
      horario: horario,
      motivoNome: motivoNome,
      veiculoNome: veiculoNome,
      centrosCusto: List<String>.of(centrosCusto),
      cpfsAcompanhantes: List<String>.of(cpfsAcompanhantes),
      origemDescricao: origemDescricao,
      origemPoint: origemPoint,
      destinoDescricao: destinoDescricao,
      destinoPoint: destinoPoint,
      paradasDescricao: List<String>.of(paradasDescricao),
      paradaPoints: paradaPoints.whereType<MapPoint>().toList(),
      objeto: objeto,
    );
  }
}

abstract class CriarSolicitacaoEvent extends Equatable {
  const CriarSolicitacaoEvent();

  @override
  List<Object?> get props => [];
}

class CatalogosSolicitados extends CriarSolicitacaoEvent {
  const CatalogosSolicitados();
}

class SolicitacaoRascunhoAtualizado extends CriarSolicitacaoEvent {
  final SolicitacaoDraft rascunho;

  const SolicitacaoRascunhoAtualizado(this.rascunho);

  @override
  List<Object?> get props => [rascunho];
}

class SolicitacaoRascunhoDescartado extends CriarSolicitacaoEvent {
  const SolicitacaoRascunhoDescartado();
}

class SolicitacaoEnviada extends CriarSolicitacaoEvent {
  final RascunhoSolicitacao rascunho;

  const SolicitacaoEnviada(this.rascunho);

  @override
  List<Object?> get props => [rascunho];
}

class SimulacaoSolicitada extends CriarSolicitacaoEvent {
  final RascunhoSolicitacao rascunho;

  const SimulacaoSolicitada(this.rascunho);

  @override
  List<Object?> get props => [rascunho];
}

class CriarSolicitacaoState extends Equatable {
  final CatalogosSolicitacao catalogos;
  final bool carregandoCatalogos;
  final bool enviando;
  final bool simulando;
  final String? erro;
  final SimulacaoSolicitacao? simulacao;
  final Solicitacao? criada;
  final SolicitacaoDraft rascunho;

  const CriarSolicitacaoState({
    this.catalogos = const CatalogosSolicitacao(),
    this.carregandoCatalogos = false,
    this.enviando = false,
    this.simulando = false,
    this.erro,
    this.simulacao,
    this.criada,
    this.rascunho = const SolicitacaoDraft(),
  });

  CriarSolicitacaoState copyWith({
    CatalogosSolicitacao? catalogos,
    bool? carregandoCatalogos,
    bool? enviando,
    bool? simulando,
    String? erro,
    SimulacaoSolicitacao? simulacao,
    Solicitacao? criada,
    SolicitacaoDraft? rascunho,
  }) {
    return CriarSolicitacaoState(
      catalogos: catalogos ?? this.catalogos,
      carregandoCatalogos: carregandoCatalogos ?? this.carregandoCatalogos,
      enviando: enviando ?? this.enviando,
      simulando: simulando ?? this.simulando,
      erro: erro,
      simulacao: simulacao ?? this.simulacao,
      criada: criada ?? this.criada,
      rascunho: rascunho ?? this.rascunho,
    );
  }

  @override
  List<Object?> get props => [
    catalogos,
    carregandoCatalogos,
    enviando,
    simulando,
    erro,
    simulacao,
    criada,
    rascunho,
  ];
}

class CriarSolicitacaoBloc
    extends Bloc<CriarSolicitacaoEvent, CriarSolicitacaoState> {
  final BuscarCatalogosUsecase buscarCatalogosUsecase;
  final SimularSolicitacaoUsecase simularSolicitacaoUsecase;
  final CriarSolicitacaoUsecase criarSolicitacaoUsecase;

  CriarSolicitacaoBloc({
    required this.buscarCatalogosUsecase,
    required this.simularSolicitacaoUsecase,
    required this.criarSolicitacaoUsecase,
  }) : super(const CriarSolicitacaoState()) {
    on<CatalogosSolicitados>(_onCatalogosSolicitados);
    on<SolicitacaoRascunhoAtualizado>(_onRascunhoAtualizado);
    on<SolicitacaoRascunhoDescartado>(_onRascunhoDescartado);
    on<SimulacaoSolicitada>(_onSimulacaoSolicitada);
    on<SolicitacaoEnviada>(_onSolicitacaoEnviada);
  }

  void _onRascunhoAtualizado(
    SolicitacaoRascunhoAtualizado event,
    Emitter<CriarSolicitacaoState> emit,
  ) {
    emit(state.copyWith(rascunho: event.rascunho));
  }

  void _onRascunhoDescartado(
    SolicitacaoRascunhoDescartado event,
    Emitter<CriarSolicitacaoState> emit,
  ) {
    emit(state.copyWith(rascunho: const SolicitacaoDraft()));
  }

  Future<void> _onSimulacaoSolicitada(
    SimulacaoSolicitada event,
    Emitter<CriarSolicitacaoState> emit,
  ) async {
    emit(state.copyWith(simulando: true));

    try {
      final nova = await _montarSolicitacao(event.rascunho);
      final simulacao = await simularSolicitacaoUsecase(nova);

      emit(state.copyWith(simulando: false, simulacao: simulacao));
    } on EnderecoNaoIdentificadoException catch (e) {
      emit(state.copyWith(simulando: false, erro: e.message));
    } on RascunhoInvalidoException catch (e) {
      emit(state.copyWith(simulando: false, erro: e.message));
    } on Failure catch (e) {
      emit(state.copyWith(simulando: false, erro: e.message));
    }
  }

  Future<void> _onCatalogosSolicitados(
    CatalogosSolicitados event,
    Emitter<CriarSolicitacaoState> emit,
  ) async {
    if (state.carregandoCatalogos) return;

    emit(state.copyWith(carregandoCatalogos: true));

    try {
      final catalogos = await buscarCatalogosUsecase();

      emit(state.copyWith(catalogos: catalogos, carregandoCatalogos: false));
    } on Failure catch (e) {
      emit(state.copyWith(carregandoCatalogos: false, erro: e.message));
    }
  }

  Future<void> _onSolicitacaoEnviada(
    SolicitacaoEnviada event,
    Emitter<CriarSolicitacaoState> emit,
  ) async {
    if (state.enviando) return;

    emit(state.copyWith(enviando: true));

    try {
      final nova = await _montarSolicitacao(event.rascunho);
      final criada = await criarSolicitacaoUsecase(nova);

      emit(state.copyWith(enviando: false, criada: criada));
    } on EnderecoNaoIdentificadoException catch (e) {
      emit(state.copyWith(enviando: false, erro: e.message));
    } on RascunhoInvalidoException catch (e) {
      emit(state.copyWith(enviando: false, erro: e.message));
    } on Failure catch (e) {
      emit(state.copyWith(enviando: false, erro: e.message));
    }
  }

  Future<NovaSolicitacao> _montarSolicitacao(
    RascunhoSolicitacao rascunho,
  ) async {
    final catalogos = state.catalogos;

    final motivoId = catalogos.idPorNome(
      rascunho.objeto ? catalogos.objetos : catalogos.motivosViagem,
      rascunho.motivoNome,
    );

    if (motivoId == null) {
      throw RascunhoInvalidoException(
        rascunho.objeto
            ? 'Selecione o objeto que será transportado.'
            : 'Selecione o motivo da corrida.',
      );
    }

    final tipoCorridaId = _resolverTipoCorrida(catalogos, rascunho.objeto);

    if (tipoCorridaId == null) {
      throw const RascunhoInvalidoException(
        'Não foi possível identificar a modalidade da corrida.',
      );
    }

    final origemPoint = rascunho.origemPoint;
    final destinoPoint = rascunho.destinoPoint;

    if (origemPoint == null || destinoPoint == null) {
      throw const RascunhoInvalidoException(
        'Selecione a origem e o destino no mapa.',
      );
    }

    final centrosCustoIds = <int>[];

    for (final valor in rascunho.centrosCusto) {
      final id = int.tryParse(valor.trim());

      if (id == null) {
        throw RascunhoInvalidoException(
          'Centro de custo inválido: ${valor.trim()}',
        );
      }

      centrosCustoIds.add(id);
    }

    if (centrosCustoIds.isEmpty) {
      throw const RascunhoInvalidoException(
        'Informe ao menos um centro de custo.',
      );
    }

    final paradas = <EnderecoEstruturado>[];

    for (var indice = 0; indice < rascunho.paradaPoints.length; indice++) {
      paradas.add(
        await resolverEnderecoEstruturado(
          rascunho.paradaPoints[indice],
          descricaoFallback: indice < rascunho.paradasDescricao.length
              ? rascunho.paradasDescricao[indice]
              : null,
        ),
      );
    }

    return NovaSolicitacao(
      dataCorrida: _combinarDataHorario(rascunho.data, rascunho.horario),
      tipoCorridaId: tipoCorridaId,
      tipoVeiculoId: catalogos.idPorNome(
        catalogos.tiposVeiculo,
        rascunho.veiculoNome,
      ),
      motivoSolicitacaoId: motivoId,
      origem: await resolverEnderecoEstruturado(
        origemPoint,
        descricaoFallback: rascunho.origemDescricao,
      ),
      destino: await resolverEnderecoEstruturado(
        destinoPoint,
        descricaoFallback: rascunho.destinoDescricao,
      ),
      paradas: paradas,
      centrosCustoIds: centrosCustoIds,
      cpfsAcompanhantes: rascunho.cpfsAcompanhantes
          .map((cpf) => cpf.trim())
          .where((cpf) => cpf.isNotEmpty)
          .toList(),
    );
  }

  int? _resolverTipoCorrida(CatalogosSolicitacao catalogos, bool objeto) {
    final idObjeto = catalogos.idTipoCorridaPorTermo('objeto');

    if (objeto) return idObjeto;

    return catalogos.idTipoCorridaPorTermo('táxi') ??
        catalogos.idTipoCorridaPorTermo('taxi') ??
        catalogos.tiposCorrida
            .where((item) => item.id != idObjeto)
            .map((item) => item.id)
            .firstOrNull;
  }

  DateTime _combinarDataHorario(String data, String horario) {
    final dataHora = combinarDataHorarioSolicitacao(data, horario);
    if (dataHora == null) {
      throw const RascunhoInvalidoException(
        'Data ou horário da corrida em formato inválido.',
      );
    }

    return dataHora;
  }
}

class RascunhoInvalidoException implements Exception {
  final String message;

  const RascunhoInvalidoException(this.message);

  @override
  String toString() => message;
}
