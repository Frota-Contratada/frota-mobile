import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/motorista_perfil.dart';
import '../dtos/response/motorista_perfil_response_dto.dart';
import '../mappers/motorista_perfil_mapper.dart';

abstract class MotoristaPerfilRemoteDatasource {
  Future<MotoristaPerfil> buscar();
}

class MotoristaPerfilRemoteDatasourceImpl
    implements MotoristaPerfilRemoteDatasource {
  final Dio dio;
  final String perfilBaseUrl;

  MotoristaPerfilRemoteDatasourceImpl({
    required this.dio,
    required this.perfilBaseUrl,
  });

  @override
  Future<MotoristaPerfil> buscar() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(perfilBaseUrl);
      final dados = response.data?['response'] as Map<String, dynamic>?;
      if (dados == null) {
        throw const ServerException('Resposta do servidor sem conteúdo.');
      }

      return MotoristaPerfilMapper.toEntity(
        MotoristaPerfilResponseDto.fromJson(dados),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
