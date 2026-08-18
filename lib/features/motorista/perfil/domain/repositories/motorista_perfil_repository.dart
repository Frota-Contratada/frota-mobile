import '../entities/motorista_perfil.dart';

abstract class MotoristaPerfilRepository {
  Future<MotoristaPerfil> buscar();
}
