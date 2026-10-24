import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/widgets/historico_filtro.dart';

void main() {
  final referencia = DateTime(2026, 8, 24, 15, 30);

  group('HistoricoFiltro', () {
    test('calcula próximos 7 dias incluindo início e fim do horizonte', () {
      final intervalo = const HistoricoFiltro(
        periodo: HistoricoPeriodo.proximos7,
      ).intervaloEm(referencia)!;

      expect(intervalo.start, DateTime(2026, 8, 24));
      expect(intervalo.end, DateTime(2026, 8, 30, 23, 59, 59, 999999));
      expect(intervalo.start.isAtSameMomentAs(DateTime(2026, 8, 24)), isTrue);
      expect(
        intervalo.end.isAtSameMomentAs(
          DateTime(2026, 8, 30, 23, 59, 59, 999999),
        ),
        isTrue,
      );
    });

    test('calcula próximos 15 e 30 dias a partir de hoje', () {
      final proximos15 = const HistoricoFiltro(
        periodo: HistoricoPeriodo.proximos15,
      ).intervaloEm(referencia)!;
      final proximos30 = const HistoricoFiltro(
        periodo: HistoricoPeriodo.proximos30,
      ).intervaloEm(referencia)!;

      expect(proximos15.start, DateTime(2026, 8, 24));
      expect(proximos15.end, DateTime(2026, 9, 7, 23, 59, 59, 999999));
      expect(proximos30.start, DateTime(2026, 8, 24));
      expect(proximos30.end, DateTime(2026, 9, 22, 23, 59, 59, 999999));
    });

    test('mantém os últimos 7 dias retrospectivos', () {
      final intervalo = const HistoricoFiltro(
        periodo: HistoricoPeriodo.ultimos7,
      ).intervaloEm(referencia)!;

      expect(intervalo.start, DateTime(2026, 8, 18));
      expect(intervalo.end, DateTime(2026, 8, 24, 23, 59, 59, 999999));
    });

    test('corresponde aos limites inclusivos do intervalo futuro', () {
      const filtro = HistoricoFiltro(periodo: HistoricoPeriodo.proximos7);
      final intervalo = filtro.intervaloEm(referencia)!;

      expect(filtro.correspondeDataEm(intervalo.start, referencia), isTrue);
      expect(filtro.correspondeDataEm(intervalo.end, referencia), isTrue);
      expect(
        filtro.correspondeDataEm(
          intervalo.end.add(const Duration(microseconds: 1)),
          referencia,
        ),
        isFalse,
      );
    });
  });
}
