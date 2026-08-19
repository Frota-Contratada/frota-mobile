import 'package:flutter/material.dart';

enum HistoricoOrdenacao { maisRecente, maisAntiga }

enum HistoricoTipo { todos, viagem, transporteItens }

enum HistoricoPeriodo { todos, hoje, ontem, ultimos7, ultimos15, ultimos30 }

class HistoricoFiltro {
  final HistoricoOrdenacao ordenacao;
  final HistoricoTipo tipo;
  final HistoricoPeriodo periodo;
  final String? statusCodigo;

  const HistoricoFiltro({
    this.ordenacao = HistoricoOrdenacao.maisRecente,
    this.tipo = HistoricoTipo.todos,
    this.periodo = HistoricoPeriodo.todos,
    this.statusCodigo,
  });

  bool get estaLimpo =>
      ordenacao == HistoricoOrdenacao.maisRecente &&
      tipo == HistoricoTipo.todos &&
      periodo == HistoricoPeriodo.todos &&
      statusCodigo == null;

  DateTimeRange? get intervalo {
    if (periodo == HistoricoPeriodo.todos) return null;

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    switch (periodo) {
      case HistoricoPeriodo.hoje:
        return DateTimeRange(start: hoje, end: _fimDoDia(hoje));
      case HistoricoPeriodo.ontem:
        final ontem = hoje.subtract(const Duration(days: 1));
        return DateTimeRange(start: ontem, end: _fimDoDia(ontem));
      case HistoricoPeriodo.ultimos7:
        return DateTimeRange(
          start: hoje.subtract(const Duration(days: 6)),
          end: _fimDoDia(hoje),
        );
      case HistoricoPeriodo.ultimos15:
        return DateTimeRange(
          start: hoje.subtract(const Duration(days: 14)),
          end: _fimDoDia(hoje),
        );
      case HistoricoPeriodo.ultimos30:
        return DateTimeRange(
          start: hoje.subtract(const Duration(days: 29)),
          end: _fimDoDia(hoje),
        );
      case HistoricoPeriodo.todos:
        return null;
    }
  }

  DateTime? get dataInicio => intervalo?.start;
  DateTime? get dataFim => intervalo?.end;

  bool correspondeTipo(String tipoCorrida) {
    final normalizado = tipoCorrida.toLowerCase();
    final ehTransporteDeItens =
        normalizado.contains('objeto') ||
        normalizado.contains('item') ||
        normalizado.contains('carga');

    switch (tipo) {
      case HistoricoTipo.todos:
        return true;
      case HistoricoTipo.viagem:
        return !ehTransporteDeItens;
      case HistoricoTipo.transporteItens:
        return ehTransporteDeItens;
    }
  }

  bool correspondeData(DateTime data) {
    final faixa = intervalo;
    if (faixa == null) return true;
    return !data.isBefore(faixa.start) && !data.isAfter(faixa.end);
  }

  bool correspondeStatus(String codigo) =>
      statusCodigo == null || statusCodigo == codigo;

  List<T> ordenar<T>(Iterable<T> itens, DateTime Function(T item) data) {
    final resultado = itens.toList();
    resultado.sort((a, b) {
      final comparacao = data(a).compareTo(data(b));
      return ordenacao == HistoricoOrdenacao.maisRecente
          ? -comparacao
          : comparacao;
    });
    return resultado;
  }

  static DateTime _fimDoDia(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day, 23, 59, 59, 999999);
}
