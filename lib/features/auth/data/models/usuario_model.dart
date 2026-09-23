import '../../domain/entities/usuario.dart';
import '../../domain/enums/perfil_usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    super.id,
    required super.nome,
    required super.email,
    super.cpf,
    super.dataAtivacao,
    super.dataDesativacao,
    super.perfil = PerfilUsuario.motorista,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int?,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String?,
      dataAtivacao: _dateFromJson(json['dataAtivacao']),
      dataDesativacao: _dateFromJson(json['dataDesativacao']),
      perfil: _perfilFromJson(json['perfil'] as String?, json['perfis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'dataAtivacao': dataAtivacao?.toIso8601String(),
      'dataDesativacao': dataDesativacao?.toIso8601String(),
      'perfil': perfil.name,
    };
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  static PerfilUsuario _perfilFromJson(String? value, dynamic perfisJson) {
    final perfis = <String>[];
    if (value != null) perfis.add(value);

    if (perfisJson is List) {
      for (final item in perfisJson) {
        if (item is String) {
          perfis.add(item);
        } else if (item is Map<String, dynamic>) {
          final tipoPerfil = item['tipoPerfil'];
          if (tipoPerfil is String) perfis.add(tipoPerfil);
        }
      }
    }

    final normalized = perfis.map((perfil) => perfil.toLowerCase()).toSet();
    if (normalized.contains('motorista')) {
      return PerfilUsuario.motorista;
    }
    if (normalized.any(
      (perfil) => {
        'passageiro',
        'solicitante',
        'solicitante-emergencia',
      }.contains(perfil),
    )) {
      return PerfilUsuario.passageiro;
    }
    return PerfilUsuario.motorista;
  }
}
