import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Usuario> buscarUsuarioPorEmail(String email) async {
    return remoteDatasource.buscarUsuarioPorEmail(email);
  }

  @override
  Future<Usuario> login({
    required String email,
    required String senha,
  }) async {
    final usuario = await remoteDatasource.login(email: email, senha: senha);
    await localDatasource.salvarUsuario(usuario);
    return usuario;
  }

  @override
  Future<void> cadastrarSenha({
    required String email,
    required String senha,
  }) async {
    await remoteDatasource.cadastrarSenha(email: email, senha: senha);
  }

  @override
  Future<void> logout() async {
    await localDatasource.removerUsuario();
  }
}