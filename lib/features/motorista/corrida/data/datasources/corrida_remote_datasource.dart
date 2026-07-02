import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../models/corrida_detalhe_model.dart';
import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../mappers/corrida_mapper.dart';

abstract class CorridaRemoteDatasource {
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId);

  Future<void> iniciarCorrida(String corridaId);
}

// MOCK — substituir por [CorridaRemoteDatasourceImpl] quando a API estiver pronta

class CorridaRemoteDatasourceMock implements CorridaRemoteDatasource {
  static List<CorridaDetalheModel> _gerarCorridasMock() {
    final hoje = DateTime.now();
    final inicioSemanaAtual = _inicioSemana(hoje);
    final diaUtilHoje = hoje.weekday <= DateTime.friday
        ? hoje.weekday - DateTime.monday
        : 0;

    CorridaDetalheModel corrida({
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
      return CorridaDetalheModel(
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
        nomePassageiro: 'Filipi Inácio Penha dos Santos',
        valorEstimado: 68.90,
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
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final corrida = _corridas.where((c) => c.id == corridaId).firstOrNull;
    if (corrida == null) {
      throw ServerException('Corrida não encontrada.');
    }

    return corrida;
  }

  @override
  Future<void> iniciarCorrida(String corridaId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final corrida = _corridas.where((c) => c.id == corridaId).firstOrNull;
    if (corrida == null) {
      throw ServerException('Corrida não encontrada.');
    }

    if (!corrida.ehProxima) {
      throw ServerException('Esta corrida ainda não pode ser iniciada.');
    }
  }
}

// IMPL REAL — trocar o Mock por esta classe quando a API estiver pronta

class CorridaRemoteDatasourceImpl implements CorridaRemoteDatasource {
  final Dio dio;
  final String corridasBaseUrl;

  CorridaRemoteDatasourceImpl({
    required this.dio,
    required this.corridasBaseUrl,
  });

  @override
  Future<CorridaDetalheModel> buscarDetalhes(String corridaId) async {
    try {
      final response = await dio.get('$corridasBaseUrl/$corridaId');

      return CorridaMapper.toCorridaDetalheModel(
        CorridaDetalheResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> iniciarCorrida(String corridaId) async {
    try {
      await dio.post('$corridasBaseUrl/$corridaId/iniciar');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
