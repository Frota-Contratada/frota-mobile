import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/auth/data/models/usuario_model.dart';
import 'package:frota_mobile/features/auth/domain/enums/perfil_usuario.dart';

void main() {
  test('reconhece a permissão de emergência nos perfis da API', () {
    final usuario = UsuarioModel.fromJson({
      'id': 1,
      'nome': 'Maria',
      'email': 'maria@empresa.com',
      'perfis': [
        {'tipoPerfil': 'solicitante'},
        {'tipoPerfil': 'solicitante-emergencia'},
      ],
    });

    expect(usuario.perfil, PerfilUsuario.passageiro);
    expect(usuario.podeSolicitarEmergencia, isTrue);
  });

  test('não concede emergência ao solicitante comum', () {
    final usuario = UsuarioModel.fromJson({
      'id': 2,
      'nome': 'João',
      'email': 'joao@empresa.com',
      'perfis': ['solicitante'],
    });

    expect(usuario.podeSolicitarEmergencia, isFalse);
  });

  test('preserva a permissão de emergência na sessão salva', () {
    const usuario = UsuarioModel(
      id: 3,
      nome: 'Ana',
      email: 'ana@empresa.com',
      perfil: PerfilUsuario.passageiro,
      podeSolicitarEmergencia: true,
    );

    final restaurado = UsuarioModel.fromJson(usuario.toJson());

    expect(restaurado.perfil, PerfilUsuario.passageiro);
    expect(restaurado.podeSolicitarEmergencia, isTrue);
  });
}
