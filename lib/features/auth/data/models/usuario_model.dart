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
      nome: json['nome'] as String,
      email: json['email'] as String,
      cpf: json['cpf'] as String?,
      dataAtivacao: json['dataAtivacao'] != null
          ? DateTime.parse(json['dataAtivacao'] as String)
          : null,
      dataDesativacao: json['dataDesativacao'] != null
          ? DateTime.parse(json['dataDesativacao'] as String)
          : null,
      perfil: _perfilFromJson(json['perfil'] as String?),
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

  static PerfilUsuario _perfilFromJson(String? value) {
    return PerfilUsuario.values.firstWhere(
      (perfil) => perfil.name == value,
      orElse: () => PerfilUsuario.motorista,
    );
  }
}
