import '../../../../../core/maps/map_point.dart';

enum SolicitarViagemModalidade { taxi }

class SolicitarViagemRouteArgs {
  final MapSelectionResult destinoInicial;
  final SolicitarViagemModalidade modalidade;

  const SolicitarViagemRouteArgs({
    required this.destinoInicial,
    this.modalidade = SolicitarViagemModalidade.taxi,
  });
}
