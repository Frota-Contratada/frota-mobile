import 'package:equatable/equatable.dart';

class CentroCusto extends Equatable {
  final int filialId;
  final int numero;
  final String nome;
  final bool ativo;
  final bool temAprovador;

  const CentroCusto({
    required this.filialId,
    required this.numero,
    required this.nome,
    required this.ativo,
    required this.temAprovador,
  });

  bool get selecionavel => ativo && temAprovador;

  String get descricao => '$numero - $nome';

  @override
  List<Object?> get props => [filialId, numero, nome, ativo, temAprovador];
}
