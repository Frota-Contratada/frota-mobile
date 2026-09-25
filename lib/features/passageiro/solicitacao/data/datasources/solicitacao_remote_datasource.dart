import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../../shared/domain/entities/item_catalogo.dart';
import '../../../solicitacoes/data/dtos/response/solicitacao_response_dto.dart';
import '../../../solicitacoes/data/mappers/solicitacoes_mapper.dart';
import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../../domain/entities/catalogos_solicitacao.dart';
import '../../domain/entities/centro_custo.dart';
import '../../domain/entities/nova_solicitacao.dart';
import '../../domain/entities/simulacao_solicitacao.dart';

const _tipoMotivoSolicitacao = 'solicitacao';

int _valorInteiro(dynamic valor) {
  if (valor is num) return valor.toInt();
  return int.tryParse(valor?.toString() ?? '') ?? 0;
}

double _valorDecimal(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor?.toString() ?? '') ?? 0;
}

DateTime? _dataResposta(dynamic valor) {
  final data = DateTime.tryParse(valor?.toString() ?? '');
  return data?.toLocal();
}

abstract class SolicitacaoRemoteDatasource {
  Future<CatalogosSolicitacao> buscarCatalogos();
  Future<SimulacaoSolicitacao> simular(NovaSolicitacao nova);
  Future<Solicitacao> criar(NovaSolicitacao nova);
}

class SolicitacaoRemoteDatasourceImpl implements SolicitacaoRemoteDatasource {
  final Dio dio;
  final String solicitacoesBaseUrl;
  final String centrosCustoBaseUrl;

  SolicitacaoRemoteDatasourceImpl({
    required this.dio,
    required this.solicitacoesBaseUrl,
    required this.centrosCustoBaseUrl,
  });

  @override
  Future<CatalogosSolicitacao> buscarCatalogos() async {
    try {
      final resultados = await Future.wait([
        _buscarMotivos(),
        _buscarItens('/tipos-veiculo', null),
        _buscarItens('/tipos-corrida', null),
      ]);
      final motivos = resultados[0];

      return CatalogosSolicitacao(
        motivosViagem: motivos,
        objetos: List<ItemCatalogo>.of(motivos),
        tiposVeiculo: resultados[1],
        tiposCorrida: resultados[2],
        centrosCusto: await _buscarCentrosCusto(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ItemCatalogo>> _buscarMotivos() async {
    try {
      final motivos = await _buscarItens('/motivos', {
        'tipo': _tipoMotivoSolicitacao,
      });

      if (motivos.isNotEmpty) return motivos;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != 400 && status != 422) rethrow;
    }

    return _buscarItens('/motivos', null);
  }

  Future<List<CentroCusto>> _buscarCentrosCusto() async {
    final response = await dio.get<Map<String, dynamic>>(centrosCustoBaseUrl);
    final lista = response.data?['response'] as List<dynamic>? ?? const [];

    return lista.map((item) {
      final centro = item as Map<String, dynamic>;
      final filialId = centro['filialId'];
      final numero = centro['numero'];

      return CentroCusto(
        filialId: filialId is num
            ? filialId.toInt()
            : int.tryParse(filialId?.toString() ?? '') ?? 0,
        numero: numero is num
            ? numero.toInt()
            : int.tryParse(numero?.toString() ?? '') ?? 0,
        nome: centro['nome'] as String? ?? '',
        ativo: centro['ativo'] as bool? ?? false,
        temAprovador: centro['temAprovador'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<SimulacaoSolicitacao> simular(NovaSolicitacao nova) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$solicitacoesBaseUrl/simulacao',
        data: nova.toSimulacaoJson(),
      );

      final dados = response.data?['response'] as Map<String, dynamic>?;

      if (dados == null) {
        throw const ServerException('Resposta do servidor sem conteúdo.');
      }

      final duracaoEstimadaMinutos = _valorInteiro(
        dados['duracaoEstimadaMinutos'],
      );
      final dataChegadaEstimada =
          _dataResposta(dados['dataChegadaEstimada']) ??
          nova.dataCorrida.add(Duration(minutes: duracaoEstimadaMinutos));

      return SimulacaoSolicitacao(
        distanciaEstimadaKm: _valorDecimal(dados['distanciaEstimadaKm']),
        duracaoEstimadaMinutos: duracaoEstimadaMinutos,
        dataChegadaEstimada: dataChegadaEstimada,
        valorEstimado: _valorDecimal(dados['valorEstimado']),
        fornecedorId: _valorInteiro(dados['fornecedorId']),
        fornecedorNome: dados['fornecedorNome'] as String? ?? '',
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Solicitacao> criar(NovaSolicitacao nova) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        solicitacoesBaseUrl,
        data: nova.toJson(),
      );

      final dados = response.data?['response'] as Map<String, dynamic>?;

      if (dados == null) {
        throw const ServerException('Resposta do servidor sem conteúdo.');
      }

      return SolicitacoesMapper.toEntity(
        SolicitacaoResponseDto.fromJson(dados),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ItemCatalogo>> _buscarItens(
    String caminho,
    Map<String, dynamic>? query,
  ) async {
    final response = await dio.get<Map<String, dynamic>>(
      '$solicitacoesBaseUrl$caminho',
      queryParameters: query,
    );

    final lista = response.data?['response'] as List<dynamic>? ?? const [];

    return lista
        .map(
          (item) => SolicitacoesMapper.toMotivo(
            CatalogoItemResponseDto.fromJson(item as Map<String, dynamic>),
          ),
        )
        .toList();
  }
}
