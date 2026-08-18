import 'package:equatable/equatable.dart';

class MotoristaHistorico extends Equatable {
  final String id;
  final DateTime dataHoraPartida;
  final String origem;
  final String destino;
  final String tipoCorrida;

  const MotoristaHistorico({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.tipoCorrida,
  });

  @override
  List<Object?> get props => [
    id,
    dataHoraPartida,
    origem,
    destino,
    tipoCorrida,
  ];
}

class MotoristaPerfil extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? fornecedorNome;
  final String? fotoPerfil;
  final int viagensFinalizadas;
  final int transportesDeItens;
  final List<MotoristaHistorico> historico;

  const MotoristaPerfil({
    required this.id,
    required this.nome,
    required this.email,
    required this.viagensFinalizadas,
    required this.transportesDeItens,
    required this.historico,
    this.cpf,
    this.fornecedorNome,
    this.fotoPerfil,
  });

  @override
  List<Object?> get props => [
    id,
    nome,
    email,
    cpf,
    fornecedorNome,
    fotoPerfil,
    viagensFinalizadas,
    transportesDeItens,
    historico,
  ];
}
