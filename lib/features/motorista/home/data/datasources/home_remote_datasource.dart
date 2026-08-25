import 'package:dio/dio.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../models/corrida_model.dart';
import '../dtos/response/corrida_response_dto.dart';
import '../mappers/home_mapper.dart';

abstract class HomeRemoteDatasource {
  Future<List<CorridaModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}

// MOCK — substituir por [HomeRemoteDatasourceImpl] quando a API estiver pronta

class HomeRemoteDatasourceMock implements HomeRemoteDatasource {
  static List<CorridaModel> _gerarCorridasMock() {
    final hoje = DateTime.now();
    final inicioSemanaAtual = _inicioSemana(hoje);
    final diaUtilHoje = hoje.weekday <= DateTime.friday
        ? hoje.weekday - DateTime.monday
        : 0;

    CorridaModel corrida({
      required String id,
      required int diasDesdeInicioSemana,
      required int hora,
      required int minuto,
      required String origem,
      required String destino,
      bool ehProxima = false,
      int? minutosRestantes,
      int semanasOffset = 0,
    }) {
      final base = inicioSemanaAtual.add(Duration(days: 7 * semanasOffset));
      return CorridaModel(
        id: id,
        dataHoraPartida: DateTime(
          base.year,
          base.month,
          base.day + diasDesdeInicioSemana,
          hora,
          minuto,
        ),
        origem: origem,
        destino: destino,
        ehProxima: ehProxima,
        minutosRestantes: minutosRestantes,
      );
    }

    return [
      corrida(
        id: '1',
        diasDesdeInicioSemana: diaUtilHoje,
        hora: 18,
        minuto: 30,
        origem: 'Rod PR-340 - km 2.5, Jaguapitã',
        destino: 'Aeroporto de Londrina',
        ehProxima: true,
        minutosRestantes: 30,
      ),
      corrida(
        id: '2',
        diasDesdeInicioSemana: diaUtilHoje,
        hora: 20,
        minuto: 30,
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
      ),
      corrida(
        id: '3',
        diasDesdeInicioSemana: diaUtilHoje + 2 <= 4 ? diaUtilHoje + 2 : 4,
        hora: 20,
        minuto: 30,
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
      ),
      corrida(
        id: '4',
        diasDesdeInicioSemana: 1,
        hora: 7,
        minuto: 0,
        origem: 'Terminal Rodoviário',
        destino: 'Fábrica Seara - Apucarana',
        semanasOffset: -1,
      ),
      corrida(
        id: '5',
        diasDesdeInicioSemana: 3,
        hora: 14,
        minuto: 15,
        origem: 'Rua das Palmeiras, 200',
        destino: 'Shopping Catuaí',
        semanasOffset: 1,
      ),
      corrida(
        id: '6',
        diasDesdeInicioSemana: 0,
        hora: 9,
        minuto: 45,
        origem: 'Av. Brasil, 1200',
        destino: 'Hospital Universitário',
        semanasOffset: 1,
      ),
    ];
  }

  static final _corridas = _gerarCorridasMock();

  static DateTime _inicioSemana(DateTime data) {
    final diasDesdeSegunda = data.weekday - DateTime.monday;
    return DateTime(data.year, data.month, data.day - diasDesdeSegunda);
  }

  @override
  Future<List<CorridaModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return _corridas.where((corrida) {
      final data = DateTime(
        corrida.dataHoraPartida.year,
        corrida.dataHoraPartida.month,
        corrida.dataHoraPartida.day,
      );
      final inicio = DateTime(
        inicioSemana.year,
        inicioSemana.month,
        inicioSemana.day,
      );
      final fim = DateTime(fimSemana.year, fimSemana.month, fimSemana.day);
      return !data.isBefore(inicio) && !data.isAfter(fim);
    }).toList()..sort((a, b) => a.dataHoraPartida.compareTo(b.dataHoraPartida));
  }
}

// IMPL REAL — trocar o Mock por esta classe quando a API estiver pronta

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio dio;
  final String viagensBaseUrl;

  HomeRemoteDatasourceImpl({required this.dio, required this.viagensBaseUrl});

  @override
  Future<List<CorridaModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        viagensBaseUrl,
        queryParameters: {
          'inicio': inicioSemana.toUtc().toIso8601String(),
          'fim': fimSemana.toUtc().toIso8601String(),
        },
      );

      final lista = response.data?['response'] as List<dynamic>? ?? const [];
      return lista
          .whereType<Map<String, dynamic>>()
          .map(
            (item) =>
                HomeMapper.toCorridaModel(CorridaResponseDto.fromJson(item)),
          )
          .toList()
        ..sort(
          (uma, outra) => uma.dataHoraPartida.compareTo(outra.dataHoraPartida),
        );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
