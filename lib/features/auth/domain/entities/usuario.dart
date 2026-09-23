import 'package:equatable/equatable.dart';
import '../enums/perfil_usuario.dart';

class Usuario extends Equatable {
  final int? id;
  final String nome;
  final String email;
  final String? cpf;
  final DateTime? dataAtivacao;
  final DateTime? dataDesativacao;
  final PerfilUsuario perfil;

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.dataAtivacao,
    this.dataDesativacao,
    this.perfil = PerfilUsuario.motorista,
  });

  @override
  List<Object?> get props => [
    id,
    nome,
    email,
    cpf,
    dataAtivacao,
    dataDesativacao,
    perfil,
  ];
}
