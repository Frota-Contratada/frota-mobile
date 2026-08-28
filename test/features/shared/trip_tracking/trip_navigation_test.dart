import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart'
    as geocoding;
import 'package:frota_mobile/config/routes.dart';
import 'package:frota_mobile/core/maps/map_point.dart';
import 'package:frota_mobile/core/maps/map_route.dart';
import 'package:frota_mobile/core/maps/routing_service.dart';
import 'package:frota_mobile/features/motorista/corrida/domain/entities/corrida_detalhe.dart';
import 'package:frota_mobile/features/motorista/corrida/domain/repositories/corrida_repository.dart';
import 'package:frota_mobile/features/motorista/corrida/domain/usecases/buscar_corrida_detalhe_usecase.dart';
import 'package:frota_mobile/features/motorista/corrida/domain/usecases/iniciar_corrida_usecase.dart';
import 'package:frota_mobile/features/motorista/corrida/domain/usecases/recusar_corrida_usecase.dart';
import 'package:frota_mobile/features/motorista/corrida/presentation/bloc/corrida.bloc.dart';
import 'package:frota_mobile/features/motorista/corrida/presentation/pages/corrida_detalhe_page.dart';
import 'package:frota_mobile/injection_container/injection_container.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'OSRM_BASE_URL=https://router.project-osrm.org',
    );
    geocoding.GeocodingPlatformFactory.instance = _FakeGeocodingFactory();
    mapRoutingService = _FakeRoutingService();
  });

  testWidgets('abre WebView após iniciar corrida em vez de voltar', (
    tester,
  ) async {
    await sl.reset();
    final repository = _CorridaRepositoryFake();
    sl.registerFactory(
      () => CorridaBloc(
        buscarCorridaDetalheUsecase: BuscarCorridaDetalheUsecase(repository),
        iniciarCorridaUsecase: IniciarCorridaUsecase(repository),
        recusarCorridaUsecase: RecusarCorridaUsecase(repository),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.motoristaCorridaDetalhe, arguments: '123'),
            child: const Text('Abrir detalhe'),
          ),
        ),
        routes: {
          AppRoutes.motoristaCorridaDetalhe: (_) => const CorridaDetalhePage(),
          AppRoutes.tripWebView: (_) =>
              const Scaffold(body: Text('WebView da corrida')),
        },
      ),
    );
    await tester.tap(find.text('Abrir detalhe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar corrida'));
    await tester.pumpAndSettle();
    expect(find.text('WebView da corrida'), findsOneWidget);
    expect(find.text('Abrir detalhe'), findsNothing);
    await sl.reset();
  });
}

class _FakeRoutingService implements RoutingService {
  @override
  Future<MapRoute?> buscarRota(List<MapPoint> pontos) async => MapRoute(
    points: pontos,
    distanceKm: 1,
    duration: const Duration(minutes: 2),
  );
}

class _FakeGeocodingFactory extends geocoding.GeocodingPlatformFactory {
  @override
  geocoding.Geocoding createGeocoding(
    geocoding.GeocodingCreationParams params,
  ) => _FakeGeocoding(params);
}

class _FakeGeocoding extends geocoding.Geocoding {
  _FakeGeocoding(super.params) : super.implementation();

  @override
  Future<List<geocoding.Location>> locationFromAddress(
    String address, {
    Locale? locale,
  }) async => const [
    geocoding.Location(latitude: -23.3045, longitude: -51.1696),
  ];
}

class _CorridaRepositoryFake implements CorridaRepository {
  final corrida = CorridaDetalhe(
    id: '123',
    dataHoraPartida: DateTime.now(),
    origem: 'Origem',
    destino: 'Destino',
    nomePassageiro: 'Passageiro',
    valorEstimado: 20,
    ehProxima: true,
  );

  @override
  Future<CorridaDetalhe> buscarDetalhes(String corridaId) async => corrida;
  @override
  Future<CorridaDetalhe> iniciarCorrida(String corridaId) async => corrida;
  @override
  Future<CorridaDetalhe> recusarCorrida(
    String corridaId,
    String motivo,
  ) async => corrida;
}
