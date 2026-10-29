import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/buscar_usuario_atual_usecase.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashCarregando extends SplashState {
  const SplashCarregando();
}

class SplashSemSessao extends SplashState {
  const SplashSemSessao();
}

class SplashSessaoRestaurada extends SplashState {
  final Usuario usuario;

  const SplashSessaoRestaurada(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class SplashCubit extends Cubit<SplashState> {
  final AuthLocalDatasource authLocalDatasource;
  final BuscarUsuarioAtualUsecase buscarUsuarioAtualUsecase;
  final Duration duracaoMinima;
  final Duration tempoLimiteSessao;

  SplashCubit({
    required this.authLocalDatasource,
    required this.buscarUsuarioAtualUsecase,
    this.duracaoMinima = const Duration(milliseconds: 1500),
    this.tempoLimiteSessao = const Duration(seconds: 8),
  }) : super(const SplashCarregando());

  Future<void> iniciar() async {
    final (usuario, _) = await (
      _restaurarSessao(),
      Future<void>.delayed(duracaoMinima),
    ).wait;
    if (isClosed) return;
    emit(
      usuario == null
          ? const SplashSemSessao()
          : SplashSessaoRestaurada(usuario),
    );
  }

  Future<Usuario?> _restaurarSessao() async {
    try {
      if (await authLocalDatasource.getAuthToken() == null) return null;
      return await buscarUsuarioAtualUsecase().timeout(tempoLimiteSessao);
    } on Object {
      return null;
    }
  }
}
