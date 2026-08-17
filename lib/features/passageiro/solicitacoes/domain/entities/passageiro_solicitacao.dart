import 'package:equatable/equatable.dart';

class PassageiroSolicitacao extends Equatable {
  final String cpf;
  final String? nome;
  final bool solicitante;

  const PassageiroSolicitacao({
    required this.cpf,
    required this.solicitante,
    this.nome,
  });

  @override
  List<Object?> get props => [cpf, nome, solicitante];
}
