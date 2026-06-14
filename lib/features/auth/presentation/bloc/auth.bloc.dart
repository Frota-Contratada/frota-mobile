  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:equatable/equatable.dart';
  import '../../domain/entities/usuario.dart';
  import '../../domain/usecases/buscar_usuario_atual_usecase.dart';
  import '../../domain/usecases/login_usecase.dart';
  import '../../domain/usecases/logout_usecase.dart';

  // Events

  abstract class AuthEvent extends Equatable {
    const AuthEvent();
    @override
    List<Object?> get props => [];
  }

  class AuthEmailSubmitted extends AuthEvent {
    final String email;
    const AuthEmailSubmitted(this.email);
    @override
    List<Object?> get props => [email];
  }

  class AuthLoginRequested extends AuthEvent {
    final String email;
    final String senha;
    const AuthLoginRequested({required this.email, required this.senha});
    @override
    List<Object?> get props => [email, senha];
  }

  class AuthCadastrarSenhaRequested extends AuthEvent {
    final String email;
    final String senha;
    final String confirmacaoSenha;
    const AuthCadastrarSenhaRequested({
      required this.email,
      required this.senha,
      required this.confirmacaoSenha,
    });
    @override
    List<Object?> get props => [email, senha, confirmacaoSenha];
  }

  class AuthLogoutRequested extends AuthEvent {}
  class AuthBackToEmailRequested extends AuthEvent {}

  // States

  abstract class AuthState extends Equatable {
    const AuthState();
    @override
    List<Object?> get props => [];
  }

  class AuthInitial extends AuthState {}

  class AuthLoading extends AuthState {}

  // E-mail válido encontrado, usuário já tem senha
  class AuthEmailValidado extends AuthState {
    final String email;
    const AuthEmailValidado(this.email);
    @override
    List<Object?> get props => [email];
  }

  // E-mail encontrado, mas é o primeiro acesso (sem senha)
  class AuthPrimeiroAcesso extends AuthState {
    final String email;
    const AuthPrimeiroAcesso(this.email);
    @override
    List<Object?> get props => [email];
  }

  class AuthAutenticado extends AuthState {
    final Usuario usuario;
    const AuthAutenticado(this.usuario);
    @override
    List<Object?> get props => [usuario];
  }

  class AuthSenhaCadastrada extends AuthState {}

  class AuthErro extends AuthState {
    final String mensagem;
    const AuthErro(this.mensagem);
    @override
    List<Object?> get props => [mensagem];
  }

  class AuthDeslogado extends AuthState {}

  // Bloc

  class AuthBloc extends Bloc<AuthEvent, AuthState> {
    final BuscarUsuarioAtualUsecase buscarUsuarioAtualUsecase;
    final LoginUsecase loginUsecase;
    final LogoutUsecase logoutUsecase;

    AuthBloc({
      required this.buscarUsuarioAtualUsecase,
      required this.loginUsecase,
      required this.logoutUsecase,
    }) : super(AuthInitial()) {
      on<AuthEmailSubmitted>(_onEmailSubmitted);
      on<AuthLoginRequested>(_onLoginRequested);
      on<AuthCadastrarSenhaRequested>(_onCadastrarSenhaRequested);
      on<AuthLogoutRequested>(_onLogoutRequested);
      on<AuthBackToEmailRequested>(_onBackToEmailRequested);
    }

    Future<void> _onEmailSubmitted(
      AuthEmailSubmitted event,
      Emitter<AuthState> emit,
    ) async {
      emit(AuthLoading());
      try {
        final usuario = await buscarUsuarioAtualUsecase(event.email);
        if (usuario.primeiroAcesso) {
          emit(AuthPrimeiroAcesso(event.email));
        } else {
          emit(AuthEmailValidado(event.email));
        }
      } catch (e) {
        emit(AuthErro(e.toString().replaceAll('Exception: ', '')));
      }
    }

    Future<void> _onLoginRequested(
      AuthLoginRequested event,
      Emitter<AuthState> emit,
    ) async {
      emit(AuthLoading());
      try {
        final usuario = await loginUsecase(
          email: event.email,
          senha: event.senha,
        );
        emit(AuthAutenticado(usuario));
      } catch (e) {
        emit(AuthErro(e.toString().replaceAll('Exception: ', '')));
      }
    }

    Future<void> _onCadastrarSenhaRequested(
      AuthCadastrarSenhaRequested event,
      Emitter<AuthState> emit,
    ) async {
      if (event.senha != event.confirmacaoSenha) {
        emit(const AuthErro('As senhas não coincidem.'));
        return;
      }
      if (event.senha.length < 6) {
        emit(const AuthErro('A senha deve ter no mínimo 6 caracteres.'));
        return;
      }
      emit(AuthLoading());
      try {
        // Chama cadastro de senha e logo em seguida faz login automático
        final usuario = await loginUsecase(
          email: event.email,
          senha: event.senha,
        );
        emit(AuthSenhaCadastrada());
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AuthAutenticado(usuario));
      } catch (e) {
        emit(AuthErro(e.toString().replaceAll('Exception: ', '')));
      }
    }

    Future<void> _onLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
    ) async {
      emit(AuthLoading());
      try {
        await logoutUsecase();
        emit(AuthDeslogado());
      } catch (_) {
        emit(AuthDeslogado());
      }
    }

    void _onBackToEmailRequested(
      AuthBackToEmailRequested event,
      Emitter<AuthState> emit,
    ) {
      emit(AuthInitial());
    }
  }
