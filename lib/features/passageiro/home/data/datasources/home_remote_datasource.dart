import 'package:dio/dio.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/status_viagem.dart';
import '../models/viagem_model.dart';
import '../dtos/response/viagem_response_dto.dart';
import '../mappers/home_mapper.dart';

abstract class PassageiroHomeRemoteDatasource {
  Future<List<ViagemModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}

class PassageiroHomeRemoteDatasourceMock implements PassageiroHomeRemoteDatasource {
  static List<ViagemModel> _gerarViagensMock() {
    final hoje = DateTime.now();
    final inicioSemanaAtual = _inicioSemana(hoje);
    final diaUtilHoje = hoje.weekday <= DateTime.friday
        ? hoje.weekday - DateTime.monday
        : 0;

    ViagemModel viagem({
      required String id,
      required int diasDesdeInicioSemana,
      required int hora,
      required int minuto,
      required String origem,
      required String destino,
      StatusViagem status = StatusViagem.agendada,
    }) {
      return ViagemModel(
        id: id,
        dataHoraPartida: DateTime(
          inicioSemanaAtual.year,
          inicioSemanaAtual.month,
          inicioSemanaAtual.day + diasDesdeInicioSemana,
          hora,
          minuto,
        ),
        origem: origem,
        destino: destino,
        status: status,
      );
    }

    return [
      viagem(
        id: '1',
        diasDesdeInicioSemana: diaUtilHoje,
        hora: 20,
        minuto: 30,
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        status: StatusViagem.emAndamento,
      ),
      viagem(
        id: '2',
        diasDesdeInicioSemana: diaUtilHoje + 2 <= 4 ? diaUtilHoje + 2 : 4,
        hora: 20,
        minuto: 30,
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
      ),
    ];
  }

  static final _viagens = _gerarViagensMock();

  static DateTime _inicioSemana(DateTime data) {
    final diasDesdeSegunda = data.weekday - DateTime.monday;
    return DateTime(data.year, data.month, data.day - diasDesdeSegunda);
  }

  @override
  Future<List<ViagemModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return _viagens.where((viagem) {
      final data = DateTime(
        viagem.dataHoraPartida.year,
        viagem.dataHoraPartida.month,
        viagem.dataHoraPartida.day,
      );
      final inicio = DateTime(
        inicioSemana.year,
        inicioSemana.month,
        inicioSemana.day,
      );
      final fim = DateTime(
        fimSemana.year,
        fimSemana.month,
        fimSemana.day,
      );
      return !data.isBefore(inicio) && !data.isAfter(fim);
    }).toList()
      ..sort((a, b) => a.dataHoraPartida.compareTo(b.dataHoraPartida));
  }
}

class PassageiroHomeRemoteDatasourceImpl implements PassageiroHomeRemoteDatasource {
  final Dio dio;
  final String viagensBaseUrl;

  PassageiroHomeRemoteDatasourceImpl({
    required this.dio,
    required this.viagensBaseUrl,
  });

  @override
  Future<List<ViagemModel>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    try {
      final response = await dio.get(
        viagensBaseUrl,
        queryParameters: {
          'inicio_semana': inicioSemana.toIso8601String(),
          'fim_semana': fimSemana.toIso8601String(),
        },
      );

      final lista = response.data as List<dynamic>;
      return lista
          .map(
            (item) => HomeMapper.toViagemModel(
              ViagemResponseDto.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
