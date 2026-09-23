import 'package:equatable/equatable.dart';

class ItemCatalogo extends Equatable {
  final int id;
  final String nome;

  final String? tipo;
  final int? capacidadePassageiros;

  const ItemCatalogo({
    required this.id,
    required this.nome,
    this.tipo,
    this.capacidadePassageiros,
  });

  @override
  List<Object?> get props => [id, nome, tipo, capacidadePassageiros];
}
