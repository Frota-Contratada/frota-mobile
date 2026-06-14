import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';

abstract class AuthLocalDatasource {
  Future<UsuarioModel?> getUsuarioLogado();
  Future<void> salvarUsuario(UsuarioModel usuario);
  Future<void> removerUsuario();
  Future<String?> getToken();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _keyUsuario = 'usuario_logado';
  static const _keyToken = 'auth_token';

  final SharedPreferences sharedPreferences;

  AuthLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<UsuarioModel?> getUsuarioLogado() async {
    final json = sharedPreferences.getString(_keyUsuario);
    if (json == null) return null;
    return UsuarioModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> salvarUsuario(UsuarioModel usuario) async {
    await sharedPreferences.setString(_keyUsuario, jsonEncode(usuario.toJson()));
    if (usuario.token != null) {
      await sharedPreferences.setString(_keyToken, usuario.token!);
    }
  }

  @override
  Future<void> removerUsuario() async {
    await sharedPreferences.remove(_keyUsuario);
    await sharedPreferences.remove(_keyToken);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(_keyToken);
  }
}