import '../entities/usuario.dart';

abstract class AuthRepository {
  // Vai mudar dependendo da implementação da Karina

  // Busca o usuário pelo e-mail. Retorna Usuario e verifica se é o primeiro acesso.
  Future<Usuario> buscarUsuarioPorEmail(String email);

  // Realiza login com e-mail e senha. Retorna Usuario com token JWT.
  Future<Usuario> login({required String email, required String senha});

  // Cadastra a senha no primeiro acesso.
  Future<void> cadastrarSenha({required String email, required String senha});

  // Realiza logout limpando o token local.
  Future<void> logout();
}