import 'package:equatable/equatable.dart';

class ItemCatalogo extends Equatable {
  final int id;
  final String nome;

  final String? tipo;

  const ItemCatalogo({required this.id, required this.nome, this.tipo});

  @override
  List<Object?> get props => [id, nome, tipo];
}
