import '../../domain/entities/corrida.dart';

class CorridaModel extends Corrida {
  const CorridaModel({
    required super.id,
    required super.dataHoraPartida,
    required super.origem,
    required super.destino,
    super.ehProxima,
    super.minutosRestantes,
  });

  factory CorridaModel.fromJson(Map<String, dynamic> json) {
    return CorridaModel(
      id: json['id'] as String,
      dataHoraPartida: DateTime.parse(json['data_hora_partida'] as String),
      origem: json['origem'] as String,
      destino: json['destino'] as String,
      ehProxima: json['eh_proxima'] as bool? ?? false,
      minutosRestantes: json['minutos_restantes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_hora_partida': dataHoraPartida.toIso8601String(),
      'origem': origem,
      'destino': destino,
      'eh_proxima': ehProxima,
      'minutos_restantes': minutosRestantes,
    };
  }
}
