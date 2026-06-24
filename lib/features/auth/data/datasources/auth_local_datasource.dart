import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_token.dart';
import '../models/usuario_model.dart';

abstract class AuthLocalDatasource {
  Future<void> salvarUsuario(UsuarioModel usuario);
  Future<void> salvarUsuarioPendente(UsuarioModel usuario);
  Future<UsuarioModel?> getUsuarioPendente();
  Future<void> removerSessao();
  Future<void> salvarAuthToken(AuthToken token);
  Future<String?> getSignUpToken();
  Future<void> salvarSignUpToken(String token);
  Future<void> limparSignUpToken();
  Future<String?> getRedefinirSenhaToken();
  Future<void> salvarRedefinirSenhaToken(String token);
  Future<void> limparRedefinirSenhaToken();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _keyUsuario = 'usuario_logado';
  static const _keyUsuarioPendente = 'usuario_pendente';
  static const _keyAuthToken = 'auth_token';
  static const _keySignUpToken = 'sign_up_token';
  static const _keyRedefinirSenhaToken = 'redefinir_senha_token';

  final SharedPreferences sharedPreferences;

  AuthLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<void> salvarUsuario(UsuarioModel usuario) async {
    await sharedPreferences.setString(
      _keyUsuario,
      jsonEncode(usuario.toJson()),
    );
  }

  @override
  Future<void> salvarUsuarioPendente(UsuarioModel usuario) async {
    await sharedPreferences.setString(
      _keyUsuarioPendente,
      jsonEncode(usuario.toJson()),
    );
  }

  @override
  Future<UsuarioModel?> getUsuarioPendente() async {
    final json = sharedPreferences.getString(_keyUsuarioPendente);
    if (json == null) return null;
    return UsuarioModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> removerSessao() async {
    await sharedPreferences.remove(_keyUsuario);
    await sharedPreferences.remove(_keyUsuarioPendente);
    await sharedPreferences.remove(_keyAuthToken);
    await sharedPreferences.remove(_keySignUpToken);
    await sharedPreferences.remove(_keyRedefinirSenhaToken);
  }

  @override
  Future<void> salvarAuthToken(AuthToken token) async {
    await sharedPreferences.setString(
      _keyAuthToken,
      jsonEncode({
        'accessToken': token.accessToken,
        'refreshToken': token.refreshToken,
        'expirationDate': token.expirationDate.toIso8601String(),
      }),
    );
  }

  @override
  Future<String?> getSignUpToken() async {
    return sharedPreferences.getString(_keySignUpToken);
  }

  @override
  Future<void> salvarSignUpToken(String token) async {
    await sharedPreferences.setString(_keySignUpToken, token);
  }

  @override
  Future<void> limparSignUpToken() async {
    await sharedPreferences.remove(_keySignUpToken);
  }

  @override
  Future<String?> getRedefinirSenhaToken() async {
    return sharedPreferences.getString(_keyRedefinirSenhaToken);
  }

  @override
  Future<void> salvarRedefinirSenhaToken(String token) async {
    await sharedPreferences.setString(_keyRedefinirSenhaToken, token);
  }

  @override
  Future<void> limparRedefinirSenhaToken() async {
    await sharedPreferences.remove(_keyRedefinirSenhaToken);
  }
}
