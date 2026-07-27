import '../entities/viagem.dart';
import '../repositories/home_repository.dart';

class PassageiroBuscarViagensPorSemanaUsecase {
  final PassageiroHomeRepository repository;

  PassageiroBuscarViagensPorSemanaUsecase(this.repository);

  Future<List<Viagem>> call({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) {
    return repository.buscarViagensPorSemana(
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
    );
  }
}
