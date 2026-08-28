import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../features/shared/trip_tracking/data/datasources/trip_position_buffer.dart';
import '../features/shared/trip_tracking/data/datasources/trip_tracking_mock_datasource.dart';
import '../features/shared/trip_tracking/data/datasources/trip_tracking_remote_datasource.dart';
import '../features/shared/trip_tracking/data/datasources/trip_tracking_socket_datasource.dart';
import '../features/shared/trip_tracking/data/repositories/trip_tracking_repository_impl.dart';
import '../features/shared/trip_tracking/domain/repositories/trip_tracking_repository.dart';
import '../features/shared/trip_tracking/presentation/bloc/trip_tracking_bloc.dart';
import '../features/shared/trip_tracking/presentation/services/passenger_distance_guard.dart';
import '../features/shared/trip_tracking/presentation/services/trip_location_service.dart';

void registerTripTrackingDependencies(GetIt sl) {
  sl.registerLazySingleton(() => TripPositionBuffer(sl()));
  if (Env.tripTrackingMock) {
    sl.registerLazySingleton<TripTrackingRemoteDatasource>(
      TripTrackingMockDatasource.new,
    );
    sl.registerLazySingleton<TripTrackingSocketDatasource>(
      NoopTripTrackingSocketDatasource.new,
    );
  } else {
    sl.registerFactory<TripTrackingRemoteDatasource>(
      () => TripTrackingRemoteDatasourceImpl(
        dio: sl(),
        baseUrl: Env.tripTrackingBaseUrl,
      ),
    );
    sl.registerFactory<TripTrackingSocketDatasource>(
      () => TripTrackingSocketDatasourceImpl(
        socketUrl: Env.tripSocketUrl,
        authLocalDatasource: sl(),
      ),
    );
  }
  sl.registerFactory<TripTrackingRepository>(
    () => TripTrackingRepositoryImpl(
      remoteDatasource: sl(),
      socketDatasource: sl(),
      positionBuffer: sl(),
    ),
  );
  sl.registerFactory(
    () => TripTrackingBloc(
      repository: sl(),
      locationService: kDebugMode && Env.tripTrackingMock
          ? SimulatedTripLocationService()
          : TripLocationService(),
      distanceGuard: PassengerDistanceGuard(
        thresholdMeters: Env.passengerDistanceAlertMeters,
        requiredConsecutiveReadings: Env.passengerDistanceAlertReadings,
      ),
    ),
  );
}
