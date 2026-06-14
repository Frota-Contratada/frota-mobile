import 'package:dio/dio.dart';
import '../../../../config/env.dart';
import '../models/usuario_model.dart';

abstract class AuthRemoteDatasource {
  Future<UsuarioModel> buscarUsuarioPorEmail(String email);
  Future<UsuarioModel> login({required String email, required String senha});
  Future<void> cadastrarSenha({required String email, required String senha});
}

// MOCK — substituir por [AuthRemoteDatasourceImpl] quando a API estiver implementada

class AuthRemoteDatasourceMock implements AuthRemoteDatasource {
  static final _usuarios = [
    UsuarioModel(
      id: '1',
      email: 'duda@seara.com.br',
      nome: 'Maria Eduarda',
      primeiroAcesso: false,
    ),
    UsuarioModel(
      id: '2',
      email: 'filipi.santos@jbs.com.br',
      nome: 'Filipi Santos',
      primeiroAcesso: true,
    ),
    UsuarioModel(
      id: '3',
      email: 'breno.silva@seara.com.br',
      nome: 'Breno Silva',
      primeiroAcesso: false,
    ),
  ];

  @override
  Future<UsuarioModel> buscarUsuarioPorEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      return _usuarios.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      throw Exception('Usuário não encontrado para o e-mail informado.');
    }
  }

  @override
  Future<UsuarioModel> login({
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    UsuarioModel usuario;
    try {
      usuario = _usuarios.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      throw Exception('E-mail ou senha inválidos.');
    }
    if (senha.length < 6) throw Exception('E-mail ou senha inválidos.');
    return usuario.copyWith(
      token: 'mock_jwt_token_${usuario.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> cadastrarSenha({
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

// IMPL REAL — trocar o Mock por esta classe quando a API estiver implementada

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<UsuarioModel> buscarUsuarioPorEmail(String email) async {
    final response = await dio.post(
      '${Env.authBaseUrl}/buscar-usuario',
      data: {'email': email},
    );
    return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UsuarioModel> login({
    required String email,
    required String senha,
  }) async {
    final response = await dio.post(
      '${Env.authBaseUrl}/login',
      data: {'email': email, 'senha': senha},
    );
    return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cadastrarSenha({
    required String email,
    required String senha,
  }) async {
    await dio.post(
      '${Env.authBaseUrl}/cadastrar-senha',
      data: {'email': email, 'senha': senha},
    );
  }
}