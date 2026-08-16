String formatarDataSolicitacao(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

String formatarHorarioSolicitacao(DateTime horario) {
  final hora = horario.hour.toString().padLeft(2, '0');
  final minuto = horario.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}
