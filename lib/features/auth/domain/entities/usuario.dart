import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final int? id;
  final String nome;
  final String email;
  final String? cpf;
  final DateTime? dataAtivacao;
  final DateTime? dataDesativacao;

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.dataAtivacao,
    this.dataDesativacao,
  });

  @override
  List<Object?> get props =>
      [id, nome, email, cpf, dataAtivacao, dataDesativacao];
}