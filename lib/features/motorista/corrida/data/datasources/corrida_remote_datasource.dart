import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../mappers/corrida_mapper.dart';
import '../models/corrida_detalhe_model.dart';

abstract class CorridaRemoteDatasource {
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId);

  Future<CorridaDetalheModel> iniciarCorrida(String corridaId);

  Future<CorridaDetalheModel> recusarCorrida(String corridaId, String motivo);
}

/// Mantido para testes locais de apresentação; a injeção usa a implementação real.
class CorridaRemoteDatasourceMock implements CorridaRemoteDatasource {
  static final _corridas = <String, CorridaDetalheModel>{
    '1': CorridaDetalheModel(
      id: '1',
      dataHoraPartida: DateTime.now().add(const Duration(minutes: 30)),
      origem: 'Rod PR-340 - km 2.5, Jaguapitã',
      destino: 'Aeroporto de Londrina',
      nomePassageiro: 'Passageiro de teste',
      valorEstimado: 68.90,
      ehProxima: true,
      minutosRestantes: 30,
    ),
  };

  @override
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final corrida = _corridas[corridaId];
    if (corrida == null) throw const ServerException('Corrida não encontrada.');
    return corrida;
  }

  @override
  Future<CorridaDetalheModel> iniciarCorrida(String corridaId) async {
    final corrida = await buscarDetalhes(corridaId);
    if (!corrida.ehProxima) {
      throw const ServerException('Esta corrida ainda não pode ser iniciada.');
    }
    return corrida;
  }

  @override
  @override
  Future<CorridaDetalheModel> recusarCorrida(
    String corridaId,
    String motivo,
  ) async {
    final corrida = await buscarDetalhes(corridaId);
    return CorridaDetalheModel(
      id: corrida.id,
      dataHoraPartida: corrida.dataHoraPartida,
      origem: corrida.origem,
      destino: corrida.destino,
      nomePassageiro: corrida.nomePassageiro,
      valorEstimado: corrida.valorEstimado,
      motivoRecusa: motivo,
    );
  }
}

class CorridaRemoteDatasourceImpl implements CorridaRemoteDatasource {
  final Dio dio;
  final String corridasBaseUrl;

  CorridaRemoteDatasourceImpl({
    required this.dio,
    required this.corridasBaseUrl,
  });

  @override
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$corridasBaseUrl/$corridaId',
      );
      return _mapResponse(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<CorridaDetalheModel> iniciarCorrida(String corridaId) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$corridasBaseUrl/$corridaId/iniciar',
      );
      final dados = response.data?['response'];
      if (dados is Map<String, dynamic>) return _mapResponse(response.data);
      return buscarDetalhes(corridaId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<CorridaDetalheModel> recusarCorrida(
    String corridaId,
    String motivo,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$corridasBaseUrl/$corridaId/recusar',
        data: {'motivo': motivo},
      );
      return _mapResponse(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  CorridaDetalheModel _mapResponse(Map<String, dynamic>? corpo) {
    final dados = corpo?['response'] as Map<String, dynamic>?;
    if (dados == null) {
      throw const ServerException('Resposta do servidor sem conteúdo.');
    }

    return CorridaMapper.toCorridaDetalheModel(
      CorridaDetalheResponseDto.fromJson(dados),
    );
  }
}
