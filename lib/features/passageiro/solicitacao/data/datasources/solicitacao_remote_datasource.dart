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

const _tipoMotivoViagem = '1';
const _tipoMotivoObjeto = '4';

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
        _buscarItens('/motivos', {'tipo': _tipoMotivoViagem}),
        _buscarItens('/motivos', {'tipo': _tipoMotivoObjeto}),
        _buscarItens('/tipos-veiculo', null),
        _buscarItens('/tipos-corrida', null),
      ]);

      return CatalogosSolicitacao(
        motivosViagem: resultados[0],
        objetos: resultados[1],
        tiposVeiculo: resultados[2],
        tiposCorrida: resultados[3],
        centrosCusto: await _buscarCentrosCusto(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CentroCusto>> _buscarCentrosCusto() async {
    final response = await dio.get<Map<String, dynamic>>(centrosCustoBaseUrl);
    final lista = response.data?['response'] as List<dynamic>? ?? const [];

    return lista.map((item) {
      final centro = item as Map<String, dynamic>;

      return CentroCusto(
        filialId: (centro['filialId'] as num?)?.toInt() ?? 0,
        numero: (centro['numero'] as num).toInt(),
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

      return SimulacaoSolicitacao(
        distanciaEstimadaKm:
            (dados['distanciaEstimadaKm'] as num?)?.toDouble() ?? 0,
        duracaoEstimadaMinutos:
            (dados['duracaoEstimadaMinutos'] as num?)?.toInt() ?? 0,
        dataChegadaEstimada: DateTime.parse(
          dados['dataChegadaEstimada'] as String,
        ).toLocal(),
        valorEstimado: (dados['valorEstimado'] as num?)?.toDouble() ?? 0,
        fornecedorId: (dados['fornecedorId'] as num?)?.toInt() ?? 0,
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
