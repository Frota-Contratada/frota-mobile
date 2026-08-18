import '../entities/motorista_perfil.dart';
import '../repositories/motorista_perfil_repository.dart';

class BuscarMotoristaPerfilUsecase {
  final MotoristaPerfilRepository repository;

  BuscarMotoristaPerfilUsecase(this.repository);

  Future<MotoristaPerfil> call() => repository.buscar();
}
