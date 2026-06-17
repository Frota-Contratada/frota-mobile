import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.email,
    required super.nome,
    super.token,
    super.primeiroAcesso,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nome: json['nome'] as String,
      token: json['token'] as String?,
      primeiroAcesso: json['primeiro_acesso'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'token': token,
      'primeiro_acesso': primeiroAcesso,
    };
  }

  UsuarioModel copyWith({
    String? id,
    String? email,
    String? nome,
    String? token,
    bool? primeiroAcesso,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      token: token ?? this.token,
      primeiroAcesso: primeiroAcesso ?? this.primeiroAcesso,
    );
  }
}