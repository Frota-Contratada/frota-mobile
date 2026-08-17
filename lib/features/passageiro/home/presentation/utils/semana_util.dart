class SemanaUtil {
  static DateTime inicioSemanaAtual([DateTime? referencia]) {
    final data = referencia ?? DateTime.now();
    final diasDesdeDomingo = data.weekday % DateTime.daysPerWeek;
    return DateTime(data.year, data.month, data.day - diasDesdeDomingo);
  }

  static DateTime fimSemanaUtil(DateTime inicioSemana) {
    return inicioSemana.add(const Duration(days: 6));
  }

  static String formatarIntervaloSemana(DateTime inicio, DateTime fim) {
    final mesInicio = _meses[inicio.month - 1];
    final mesFim = _meses[fim.month - 1];

    if (inicio.month == fim.month) {
      return '${inicio.day}-${fim.day} de $mesInicio';
    }

    return '${inicio.day} de $mesInicio - ${fim.day} de $mesFim';
  }

  static String formatarDiaViagem(DateTime data) {
    final hoje = DateTime.now();
    final dataSemHora = DateTime(data.year, data.month, data.day);
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';

    if (dataSemHora == hojeSemHora) {
      return 'Hoje - $dataFormatada';
    }

    final amanha = hojeSemHora.add(const Duration(days: 1));
    if (dataSemHora == amanha) {
      return 'Amanhã - $dataFormatada';
    }

    return '${_diasSemana[data.weekday - 1]} $dataFormatada';
  }

  static String formatarHorario(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '${hora}h$minuto';
  }

  static const _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const _diasSemana = [
    'Segunda-Feira',
    'Terça-Feira',
    'Quarta-Feira',
    'Quinta-Feira',
    'Sexta-Feira',
    'Sábado',
    'Domingo',
  ];
}
