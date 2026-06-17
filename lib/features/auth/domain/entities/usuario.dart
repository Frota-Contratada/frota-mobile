import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String email;
  final String nome;
  final String? token;
  final bool primeiroAcesso;

  const Usuario({
    required this.id,
    required this.email,
    required this.nome,
    this.token,
    this.primeiroAcesso = false,
  });

  @override
  List<Object?> get props => [id, email, nome, token, primeiroAcesso];
}