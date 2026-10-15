import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/preferencias_notificacao.dart';
import '../dtos/response/preferencias_notificacao_response_dto.dart';

abstract class PreferenciasNotificacaoRemoteDatasource {
  Future<PreferenciasNotificacao> buscar();
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  });
}

class PreferenciasNotificacaoRemoteDatasourceImpl
    implements PreferenciasNotificacaoRemoteDatasource {
  final Dio dio;
  final String notificacoesBaseUrl;

  PreferenciasNotificacaoRemoteDatasourceImpl({
    required this.dio,
    required this.notificacoesBaseUrl,
  });

  String get _url => '$notificacoesBaseUrl/preferencias';

  @override
  Future<PreferenciasNotificacao> buscar() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(_url);
      return _converter(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  }) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        _url,
        data: {
          'pushAtivo': ?pushAtivo,
          if (categorias != null && categorias.isNotEmpty)
            'categorias': {
              for (final entrada in categorias.entries)
                entrada.key.codigo: entrada.value,
            },
        },
      );
      return _converter(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  PreferenciasNotificacao _converter(Object? payload) {
    if (payload is! Map || payload['response'] is! Map) {
      throw const ServerException('Resposta de preferências inválida.');
    }
    try {
      return PreferenciasNotificacaoResponseDto.fromJson(
        Map<String, dynamic>.from(payload['response'] as Map),
      ).toEntity();
    } on FormatException catch (e) {
      throw ServerException(e.message);
    }
  }
}
