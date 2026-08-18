import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failure_mapper.dart';
import '../../domain/entities/motorista_perfil.dart';
import '../../domain/repositories/motorista_perfil_repository.dart';
import '../datasources/motorista_perfil_remote_datasource.dart';

class MotoristaPerfilRepositoryImpl implements MotoristaPerfilRepository {
  final MotoristaPerfilRemoteDatasource remoteDatasource;

  MotoristaPerfilRepositoryImpl({required this.remoteDatasource});

  @override
  Future<MotoristaPerfil> buscar() async {
    try {
      return await remoteDatasource.buscar();
    } on ServerException catch (e) {
      throw mapServerException(e);
    }
  }
}
