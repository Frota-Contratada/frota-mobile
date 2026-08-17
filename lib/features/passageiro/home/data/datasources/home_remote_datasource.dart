import 'package:dio/dio.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../models/viagem_model.dart';
import '../dtos/response/viagem_response_dto.dart';
import '../mappers/home_mapper.dart';

abstract class PassageiroHomeRemoteDatasource {
  Future<List<ViagemModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}

class PassageiroHomeRemoteDatasourceImpl
    implements PassageiroHomeRemoteDatasource {
  final Dio dio;

  /// `GET /solicitacoes/viagens`
  final String viagensBaseUrl;

  PassageiroHomeRemoteDatasourceImpl({
    required this.dio,
    required this.viagensBaseUrl,
  });

  @override
  Future<List<ViagemModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        viagensBaseUrl,
        // Em UTC para o backend não reinterpretar o horário no fuso dele.
        queryParameters: {
          'inicio': inicioSemana.toUtc().toIso8601String(),
          'fim': fimSemana.toUtc().toIso8601String(),
        },
      );

      final lista = response.data?['response'] as List<dynamic>? ?? const [];

      return lista
          .map(
            (item) => HomeMapper.toViagemModel(
              ViagemResponseDto.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList()
        ..sort(
          (uma, outra) => uma.dataHoraPartida.compareTo(outra.dataHoraPartida),
        );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
