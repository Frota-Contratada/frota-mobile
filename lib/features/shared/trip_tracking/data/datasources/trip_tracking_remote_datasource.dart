import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/canonical_route.dart';
import '../../domain/entities/tracked_position.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';
import '../../domain/entities/trip_waiting_state.dart';

abstract class TripTrackingRemoteDatasource {
  Future<TripTrackingSnapshot> loadSnapshot(String tripId, TripRole role);
  Future<void> sendPositions(String tripId, List<TrackedPosition> positions);
  Future<void> sendPassengerPosition(String tripId, TrackedPosition position);
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  );
  Future<TripWaitingState> confirmWaiting(String tripId, String commandEventId);
  Future<TripWaitingState> resumeWaiting(String tripId, String commandEventId);
  Future<void> finishTrip(String tripId, String commandEventId);
}

class TripTrackingRemoteDatasourceImpl implements TripTrackingRemoteDatasource {
  final Dio dio;
  final String baseUrl;

  TripTrackingRemoteDatasourceImpl({required this.dio, required this.baseUrl});

  String _trip(String id) => '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/$id';

  Options _commandOptions(String commandEventId) =>
      Options(headers: {'Idempotency-Key': commandEventId});

  @override
  Future<TripTrackingSnapshot> loadSnapshot(
    String tripId,
    TripRole role,
  ) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${_trip(tripId)}/tracking',
      );
      final data = _responseMap(response.data);
      return TripTrackingSnapshot.fromJson(data, tripId: tripId, role: role);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException('Resposta inválida do servidor.');
    }
  }

  @override
  Future<void> sendPositions(
    String tripId,
    List<TrackedPosition> positions,
  ) async {
    if (positions.isEmpty) return;
    try {
      await dio.post<void>(
        '${_trip(tripId)}/tracking/positions/batch',
        data: {'positions': positions.map((item) => item.toJson()).toList()},
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> sendPassengerPosition(
    String tripId,
    TrackedPosition position,
  ) async {
    try {
      await dio.post<void>(
        '${_trip(tripId)}/tracking/passenger-position',
        data: position.toJson(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${_trip(tripId)}/route/reroute',
        data: {'position': position.toJson()},
        options: _commandOptions(commandEventId),
      );
      return CanonicalRoute.fromJson(_responseMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException('Resposta inválida do servidor.');
    }
  }

  @override
  Future<TripWaitingState> confirmWaiting(
    String tripId,
    String commandEventId,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${_trip(tripId)}/waiting/start',
        options: _commandOptions(commandEventId),
      );
      return TripWaitingState.fromJson(_responseMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException('Resposta inválida do servidor.');
    }
  }

  @override
  Future<TripWaitingState> resumeWaiting(
    String tripId,
    String commandEventId,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${_trip(tripId)}/waiting/resume',
        options: _commandOptions(commandEventId),
      );
      return TripWaitingState.fromJson(_responseMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException('Resposta inválida do servidor.');
    }
  }

  @override
  Future<void> finishTrip(String tripId, String commandEventId) async {
    try {
      await dio.post<void>(
        '${_trip(tripId)}/finish',
        options: _commandOptions(commandEventId),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _responseMap(Map<String, dynamic>? body) {
    final response = body?['response'];
    if (response is Map) return Map<String, dynamic>.from(response);
    if (body != null && body.isNotEmpty) return body;
    throw const ServerException('Resposta inválida do servidor.');
  }
}
