import '../../../../config/routes.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/enums/perfil_usuario.dart';

class AuthNavigation {
  static String rotaHome(Usuario usuario) {
    return switch (usuario.perfil) {
      PerfilUsuario.motorista => AppRoutes.motoristaHome,
      PerfilUsuario.passageiro => AppRoutes.passageiroHome,
    };
  }
}
