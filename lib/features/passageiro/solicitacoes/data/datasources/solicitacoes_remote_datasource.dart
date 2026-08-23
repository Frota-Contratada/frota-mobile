import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/motivo.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/entities/status_solicitacao.dart';
import '../dtos/response/solicitacao_response_dto.dart';
import '../mappers/solicitacoes_mapper.dart';

abstract class SolicitacoesRemoteDatasource {
  Future<PaginaSolicitacoes> buscarVarias({
    StatusSolicitacao? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page,
    int limit,
    bool historico,
    bool incluirAnteriores,
  });

  Future<Solicitacao> buscar(int id);

  Future<Solicitacao> cancelar({
    required int id,
    required int motivoCancelamentoId,
  });

  Future<List<Motivo>> buscarMotivos(String tipo);
}

class SolicitacoesRemoteDatasourceImpl implements SolicitacoesRemoteDatasource {
  final Dio dio;
  final String solicitacoesBaseUrl;

  SolicitacoesRemoteDatasourceImpl({
    required this.dio,
    required this.solicitacoesBaseUrl,
  });

  @override
  Future<PaginaSolicitacoes> buscarVarias({
    StatusSolicitacao? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 50,
    bool historico = false,
    bool incluirAnteriores = false,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        solicitacoesBaseUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status.codigo,
          if (dataInicio != null)
            'dataInicio': dataInicio.toUtc().toIso8601String(),
          if (dataFim != null) 'dataFim': dataFim.toUtc().toIso8601String(),
          if (historico) 'historico': 'true',
          if (incluirAnteriores) 'incluirAnteriores': 'true',
        },
      );

      final pagina = response.data?['response'] as Map<String, dynamic>? ?? {};
      final itens = pagina['data'] as List<dynamic>? ?? const [];

      return PaginaSolicitacoes(
        itens: itens
            .map(
              (item) => SolicitacoesMapper.toEntity(
                SolicitacaoResponseDto.fromJson(item as Map<String, dynamic>),
              ),
            )
            .toList(),
        totalCount: (pagina['totalCount'] as num?)?.toInt() ?? 0,
        hasNextPage: pagina['hasNextPage'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Solicitacao> buscar(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$solicitacoesBaseUrl/$id',
      );

      return _paraSolicitacao(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Solicitacao> cancelar({
    required int id,
    required int motivoCancelamentoId,
  }) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '$solicitacoesBaseUrl/$id/cancelamento',
        data: {'motivoCancelamentoId': motivoCancelamentoId},
      );

      return _paraSolicitacao(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<Motivo>> buscarMotivos(String tipo) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$solicitacoesBaseUrl/motivos',
        queryParameters: {'tipo': tipo},
      );

      final lista = response.data?['response'] as List<dynamic>? ?? const [];

      return lista
          .map(
            (item) => SolicitacoesMapper.toMotivo(
              CatalogoItemResponseDto.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Solicitacao _paraSolicitacao(Map<String, dynamic>? corpo) {
    final dados = corpo?['response'] as Map<String, dynamic>?;

    if (dados == null) {
      throw const ServerException('Resposta do servidor sem conteúdo.');
    }

    return SolicitacoesMapper.toEntity(SolicitacaoResponseDto.fromJson(dados));
  }
}
