import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/preferencias_notificacao.dart';
import '../../domain/usecases/atualizar_preferencia_notificacao_usecase.dart';
import '../../domain/usecases/buscar_preferencias_notificacao_usecase.dart';

abstract class PreferenciasNotificacaoEvent extends Equatable {
  const PreferenciasNotificacaoEvent();

  @override
  List<Object?> get props => [];
}

class PreferenciasNotificacaoCarregadas extends PreferenciasNotificacaoEvent {
  const PreferenciasNotificacaoCarregadas();
}

class PreferenciaPushAlterada extends PreferenciasNotificacaoEvent {
  final bool ativo;

  const PreferenciaPushAlterada(this.ativo);

  @override
  List<Object?> get props => [ativo];
}

class PreferenciaCategoriaAlterada extends PreferenciasNotificacaoEvent {
  final CategoriaNotificacao categoria;
  final bool ativa;

  const PreferenciaCategoriaAlterada(this.categoria, this.ativa);

  @override
  List<Object?> get props => [categoria, ativa];
}

abstract class PreferenciasNotificacaoState extends Equatable {
  const PreferenciasNotificacaoState();

  @override
  List<Object?> get props => [];
}

class PreferenciasNotificacaoInitial extends PreferenciasNotificacaoState {
  const PreferenciasNotificacaoInitial();
}

class PreferenciasNotificacaoLoading extends PreferenciasNotificacaoState {
  const PreferenciasNotificacaoLoading();
}

class ErroSalvamentoPreferencia extends Equatable {
  final int sequencia;
  final String mensagem;

  const ErroSalvamentoPreferencia(this.sequencia, this.mensagem);

  @override
  List<Object?> get props => [sequencia, mensagem];
}

class PreferenciasNotificacaoCarregada extends PreferenciasNotificacaoState {
  static const chavePush = 'pushAtivo';

  final PreferenciasNotificacao preferencias;
  final Set<String> salvando;
  final ErroSalvamentoPreferencia? erroSalvamento;

  const PreferenciasNotificacaoCarregada({
    required this.preferencias,
    this.salvando = const {},
    this.erroSalvamento,
  });

  bool estaSalvando(String chave) => salvando.contains(chave);

  PreferenciasNotificacaoCarregada copiar({
    PreferenciasNotificacao? preferencias,
    Set<String>? salvando,
    ErroSalvamentoPreferencia? erroSalvamento,
  }) => PreferenciasNotificacaoCarregada(
    preferencias: preferencias ?? this.preferencias,
    salvando: salvando ?? this.salvando,
    erroSalvamento: erroSalvamento ?? this.erroSalvamento,
  );

  @override
  List<Object?> get props => [preferencias, salvando, erroSalvamento];
}

class PreferenciasNotificacaoErro extends PreferenciasNotificacaoState {
  final String mensagem;
  final bool semConexao;

  const PreferenciasNotificacaoErro(this.mensagem, {this.semConexao = false});

  @override
  List<Object?> get props => [mensagem, semConexao];
}

class PreferenciasNotificacaoBloc
    extends Bloc<PreferenciasNotificacaoEvent, PreferenciasNotificacaoState> {
  final BuscarPreferenciasNotificacaoUsecase buscarPreferencias;
  final AtualizarPreferenciaNotificacaoUsecase atualizarPreferencia;
  int _sequenciaErro = 0;

  PreferenciasNotificacaoBloc({
    required this.buscarPreferencias,
    required this.atualizarPreferencia,
  }) : super(const PreferenciasNotificacaoInitial()) {
    on<PreferenciasNotificacaoCarregadas>(_onCarregadas);
    on<PreferenciaPushAlterada>(_onPushAlterada);
    on<PreferenciaCategoriaAlterada>(_onCategoriaAlterada);
  }

  Future<void> _onCarregadas(
    PreferenciasNotificacaoCarregadas event,
    Emitter<PreferenciasNotificacaoState> emit,
  ) async {
    emit(const PreferenciasNotificacaoLoading());
    try {
      emit(
        PreferenciasNotificacaoCarregada(
          preferencias: await buscarPreferencias(),
        ),
      );
    } on Failure catch (e) {
      emit(
        PreferenciasNotificacaoErro(
          e.message,
          semConexao: e is NetworkFailure,
        ),
      );
    } on Object {
      emit(
        const PreferenciasNotificacaoErro(
          'Não foi possível carregar as preferências.',
        ),
      );
    }
  }

  Future<void> _onPushAlterada(
    PreferenciaPushAlterada event,
    Emitter<PreferenciasNotificacaoState> emit,
  ) => _salvar(
    emit,
    chave: PreferenciasNotificacaoCarregada.chavePush,
    aplicar: (p) => p.comPush(event.ativo),
    reverter: (atual, anterior) => atual.comPush(anterior.pushAtivo),
    confirmar: (atual, servidor) => atual.comPush(servidor.pushAtivo),
    salvar: () => atualizarPreferencia.push(event.ativo),
  );

  Future<void> _onCategoriaAlterada(
    PreferenciaCategoriaAlterada event,
    Emitter<PreferenciasNotificacaoState> emit,
  ) => _salvar(
    emit,
    chave: event.categoria.codigo,
    aplicar: (p) => p.comCategoria(event.categoria, event.ativa),
    reverter: (atual, anterior) =>
        atual.comCategoria(event.categoria, anterior.ativa(event.categoria)),
    confirmar: (atual, servidor) =>
        atual.comCategoria(event.categoria, servidor.ativa(event.categoria)),
    salvar: () => atualizarPreferencia.categoria(event.categoria, event.ativa),
  );

  Future<void> _salvar(
    Emitter<PreferenciasNotificacaoState> emit, {
    required String chave,
    required PreferenciasNotificacao Function(PreferenciasNotificacao) aplicar,
    required PreferenciasNotificacao Function(
      PreferenciasNotificacao atual,
      PreferenciasNotificacao anterior,
    )
    reverter,
    required PreferenciasNotificacao Function(
      PreferenciasNotificacao atual,
      PreferenciasNotificacao servidor,
    )
    confirmar,
    required Future<PreferenciasNotificacao> Function() salvar,
  }) async {
    final inicial = state;
    if (inicial is! PreferenciasNotificacaoCarregada ||
        inicial.estaSalvando(chave)) {
      return;
    }

    final anterior = inicial.preferencias;
    emit(
      inicial.copiar(
        preferencias: aplicar(anterior),
        salvando: {...inicial.salvando, chave},
      ),
    );

    try {
      final servidor = await salvar();
      final atual = state as PreferenciasNotificacaoCarregada;
      emit(
        atual.copiar(
          preferencias: confirmar(atual.preferencias, servidor),
          salvando: {...atual.salvando}..remove(chave),
        ),
      );
    } on Object catch (e) {
      final atual = state as PreferenciasNotificacaoCarregada;
      emit(
        atual.copiar(
          preferencias: reverter(atual.preferencias, anterior),
          salvando: {...atual.salvando}..remove(chave),
          erroSalvamento: ErroSalvamentoPreferencia(
            ++_sequenciaErro,
            e is Failure ? e.message : 'Não foi possível salvar a preferência.',
          ),
        ),
      );
    }
  }
}
