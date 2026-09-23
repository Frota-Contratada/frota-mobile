import '../../domain/enums/perfil_usuario.dart';
import '../models/usuario_model.dart';

class AuthMockUsuarios {
  static const senha = '123456';
  static const pin = '123456';

  static const motorista = UsuarioModel(
    id: 1,
    nome: 'Antônio Gonçalves',
    email: 'motorista@frota.com.br',
    perfil: PerfilUsuario.motorista,
  );

  static const passageiro = UsuarioModel(
    id: 2,
    nome: 'Maria Julia',
    email: 'passageiro@frota.com.br',
    perfil: PerfilUsuario.passageiro,
  );

  static const usuarios = [motorista, passageiro];

  static UsuarioModel? buscarPorEmail(String emailInformado) {
    final emailNormalizado = emailInformado.trim().toLowerCase();
    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == emailNormalizado) {
        return usuario;
      }
    }
    return null;
  }
}
