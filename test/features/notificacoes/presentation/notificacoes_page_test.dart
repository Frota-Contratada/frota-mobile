import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/notificacao.dart';
import 'package:frota_mobile/features/notificacoes/domain/repositories/notificacoes_repository.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/buscar_notificacoes_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/contar_notificacoes_nao_lidas_usecase.dart';
import 'package:frota_mobile/features/notificacoes/domain/usecases/marcar_notificacao_como_lida_usecase.dart';
import 'package:frota_mobile/features/notificacoes/presentation/bloc/notificacoes_bloc.dart';
import 'package:frota_mobile/features/notificacoes/presentation/pages/notificacoes_page.dart';

void main() {
  testWidgets('exibe o título e o carregamento inicial', (tester) async {
    final repository = _EmptyRepository();
    final bloc = NotificacoesBloc(
      buscarNotificacoesUsecase: BuscarNotificacoesUsecase(repository),
      contarNotificacoesNaoLidasUsecase: ContarNotificacoesNaoLidasUsecase(
        repository,
      ),
      marcarNotificacaoComoLidaUsecase: MarcarNotificacaoComoLidaUsecase(
        repository,
      ),
      repository: repository,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const NotificacoesPage()),
      ),
    );
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _EmptyRepository implements NotificacoesRepository {
  @override
  Stream<Notificacao> get notificacoesCriadas => const Stream.empty();

  @override
  Stream<String> get notificacoesRemovidas => const Stream.empty();

  @override
  Future<List<Notificacao>> buscarTodas() async => [];

  @override
  Future<int> contarNaoLidas() async => 0;

  @override
  Future<Notificacao> marcarComoLida(String id) async =>
      throw UnimplementedError();

  @override
  Future<void> conectar() async {}

  @override
  Future<void> desconectar() async {}
}
