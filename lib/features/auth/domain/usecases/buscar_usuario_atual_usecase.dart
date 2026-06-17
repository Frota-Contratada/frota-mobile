import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class BuscarUsuarioAtualUsecase {
  final AuthRepository repository;

  BuscarUsuarioAtualUsecase(this.repository);

  Future<Usuario> call(String email) async {
    return repository.buscarUsuarioPorEmail(email);
  }
}