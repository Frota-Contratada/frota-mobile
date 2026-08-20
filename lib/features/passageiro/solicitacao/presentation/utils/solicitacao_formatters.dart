import 'package:flutter/material.dart';

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

DateTime? parseDataSolicitacao(String value) {
  if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) return null;

  final partes = value.split('/');
  final dia = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final ano = int.tryParse(partes[2]);
  if (dia == null || mes == null || ano == null) return null;

  final data = DateTime(ano, mes, dia);
  if (data.year != ano || data.month != mes || data.day != dia) return null;

  return data;
}

TimeOfDay? parseHorarioSolicitacao(String value) {
  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) return null;

  final partes = value.split(':');
  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);
  if (hora == null || minuto == null || hora > 23 || minuto > 59) {
    return null;
  }

  return TimeOfDay(hour: hora, minute: minuto);
}

DateTime? combinarDataHorarioSolicitacao(String data, String horario) {
  final dataParsed = parseDataSolicitacao(data);
  final horarioParsed = parseHorarioSolicitacao(horario);
  if (dataParsed == null || horarioParsed == null) return null;

  return DateTime(
    dataParsed.year,
    dataParsed.month,
    dataParsed.day,
    horarioParsed.hour,
    horarioParsed.minute,
  );
}

bool dataHoraSolicitacaoValida(
  DateTime data,
  TimeOfDay horario, {
  DateTime? agora,
}) {
  final dataHora = DateTime(
    data.year,
    data.month,
    data.day,
    horario.hour,
    horario.minute,
  );
  return dataHora.isAfter(agora ?? DateTime.now());
}
