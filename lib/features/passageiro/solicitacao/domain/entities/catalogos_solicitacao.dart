import 'package:equatable/equatable.dart';
import '../../../shared/domain/entities/item_catalogo.dart';
import 'centro_custo.dart';

class CatalogosSolicitacao extends Equatable {
  final List<ItemCatalogo> motivosViagem;

  final List<ItemCatalogo> objetos;
  final List<ItemCatalogo> tiposVeiculo;
  final List<ItemCatalogo> tiposCorrida;
  final List<CentroCusto> centrosCusto;

  const CatalogosSolicitacao({
    this.motivosViagem = const [],
    this.objetos = const [],
    this.tiposVeiculo = const [],
    this.tiposCorrida = const [],
    this.centrosCusto = const [],
  });

  List<CentroCusto> get centrosCustoSelecionaveis =>
      centrosCusto.where((centro) => centro.selecionavel).toList();

  List<String> get nomesMotivosViagem =>
      motivosViagem.map((item) => item.nome).toList();

  List<String> get nomesObjetos => objetos.map((item) => item.nome).toList();

  List<String> get nomesTiposVeiculo =>
      tiposVeiculo.map((item) => item.nome).toList();

  int? idPorNome(List<ItemCatalogo> itens, String? nome) {
    if (nome == null) return null;

    for (final item in itens) {
      if (item.nome == nome) return item.id;
    }

    return null;
  }

  int? idTipoCorridaPorTermo(String termo) {
    final alvo = termo.toLowerCase();

    for (final item in tiposCorrida) {
      if (item.nome.toLowerCase().contains(alvo)) return item.id;
    }

    return null;
  }

  @override
  List<Object?> get props => [
    motivosViagem,
    objetos,
    tiposVeiculo,
    tiposCorrida,
    centrosCusto,
  ];
}
