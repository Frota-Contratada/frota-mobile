import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/passageiro/home/domain/entities/viagem.dart';
import 'package:frota_mobile/features/passageiro/home/domain/repositories/home_repository.dart';
import 'package:frota_mobile/features/passageiro/home/domain/usecases/buscar_viagens_por_semana_usecase.dart';
import 'package:frota_mobile/features/passageiro/home/presentation/bloc/home.bloc.dart';

class _RepositorioFake implements PassageiroHomeRepository {
  final List<List<Viagem>> respostas;
  final semanasConsultadas = <DateTime>[];

  _RepositorioFake(this.respostas);

  @override
  Future<List<Viagem>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) async {
    semanasConsultadas.add(inicioSemana);
    return respostas.removeAt(0);
  }
}

Viagem _viagem(String id) => Viagem(
  id: id,
  dataHoraPartida: DateTime(2026, 10, 21, 9),
  origem: 'Origem',
  destino: 'Destino',
);

void main() {
  test(
    'atualiza as viagens da semana exibida sem voltar ao carregamento',
    () async {
      final repositorio = _RepositorioFake([
        [_viagem('1')],
        [_viagem('1'), _viagem('2')],
      ]);
      final bloc = PassageiroHomeBloc(
        buscarViagensPorSemanaUsecase: PassageiroBuscarViagensPorSemanaUsecase(
          repositorio,
        ),
      );

      bloc.add(const PassageiroHomeIniciada());
      final carregada =
          await bloc.stream.firstWhere(
                (estado) => estado is PassageiroHomeCarregada,
              )
              as PassageiroHomeCarregada;

      final estados = <PassageiroHomeState>[];
      final assinatura = bloc.stream.listen(estados.add);
      final concluido = Completer<void>();
      bloc.add(PassageiroHomeAtualizada(concluido: concluido));
      await concluido.future;
      await Future<void>.delayed(Duration.zero);
      await assinatura.cancel();

      expect(estados.whereType<PassageiroHomeLoading>(), isEmpty);
      expect((bloc.state as PassageiroHomeCarregada).viagens.map((v) => v.id), [
        '1',
        '2',
      ]);
      expect(repositorio.semanasConsultadas, [
        carregada.inicioSemana,
        carregada.inicioSemana,
      ]);

      await bloc.close();
    },
  );

  test(
    'conclui a atualização mesmo antes de a tela terminar de carregar',
    () async {
      final bloc = PassageiroHomeBloc(
        buscarViagensPorSemanaUsecase: PassageiroBuscarViagensPorSemanaUsecase(
          _RepositorioFake([]),
        ),
      );
      final concluido = Completer<void>();

      bloc.add(PassageiroHomeAtualizada(concluido: concluido));

      await expectLater(
        concluido.future.timeout(const Duration(seconds: 2)),
        completes,
      );
      await bloc.close();
    },
  );
}
