import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/enums/tipo_token.dart';
import '../../domain/usecases/confirmar_pin_usecase.dart';
import '../../domain/usecases/enviar_pin_email_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/redefinir_senha_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verificar_email_usecase.dart';

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

class AuthPinSubmitted extends AuthEvent {
  final String email;
  final String pin;
  const AuthPinSubmitted({required this.email, required this.pin});
  @override
  List<Object?> get props => [email, pin];
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

class AuthEsqueciSenhaRequested extends AuthEvent {
  final String email;
  const AuthEsqueciSenhaRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthRedefinirSenhaPinSubmitted extends AuthEvent {
  final String email;
  final String pin;
  const AuthRedefinirSenhaPinSubmitted({
    required this.email,
    required this.pin,
  });
  @override
  List<Object?> get props => [email, pin];
}

class AuthRedefinirSenhaRequested extends AuthEvent {
  final String email;
  final String senha;
  final String confirmacaoSenha;
  const AuthRedefinirSenhaRequested({
    required this.email,
    required this.senha,
    required this.confirmacaoSenha,
  });
  @override
  List<Object?> get props => [email, senha, confirmacaoSenha];
}

class AuthBackToEmailRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}
class AuthBackToSenhaRequested extends AuthEvent {
  final String email;
  const AuthBackToSenhaRequested(this.email);
  @override
  List<Object?> get props => [email];
}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthEmailValidado extends AuthState {
  final String email;
  final String? erro;
  const AuthEmailValidado(this.email, {this.erro});
  @override
  List<Object?> get props => [email, erro];
}

class AuthPrimeiroAcesso extends AuthState {
  final String email;
  final String? erro;
  const AuthPrimeiroAcesso(this.email, {this.erro});
  @override
  List<Object?> get props => [email, erro];
}

class AuthCadastroSenha extends AuthState {
  final String email;
  final String? erro;
  const AuthCadastroSenha(this.email, {this.erro});
  @override
  List<Object?> get props => [email, erro];
}

class AuthRedefinirSenhaPin extends AuthState {
  final String email;
  final String? erro;
  const AuthRedefinirSenhaPin(this.email, {this.erro});
  @override
  List<Object?> get props => [email, erro];
}

class AuthRedefinirSenhaNovaSenha extends AuthState {
  final String email;
  final String? erro;
  const AuthRedefinirSenhaNovaSenha(this.email, {this.erro});
  @override
  List<Object?> get props => [email, erro];
}

class AuthAutenticado extends AuthState {
  final Usuario usuario;
  const AuthAutenticado(this.usuario);
  @override
  List<Object?> get props => [usuario];
}

class AuthErro extends AuthState {
  final String mensagem;
  const AuthErro(this.mensagem);
  @override
  List<Object?> get props => [mensagem];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerificarEmailUsecase verificarEmailUsecase;
  final LoginUsecase loginUsecase;
  final SignUpUsecase signUpUsecase;
  final LogoutUsecase logoutUsecase;
  final ConfirmarPinUsecase confirmarPinUsecase;
  final EnviarPinEmailUsecase enviarPinEmailUsecase;
  final RedefinirSenhaUsecase redefinirSenhaUsecase;

  AuthBloc({
    required this.verificarEmailUsecase,
    required this.loginUsecase,
    required this.signUpUsecase,
    required this.logoutUsecase,
    required this.confirmarPinUsecase,
    required this.enviarPinEmailUsecase,
    required this.redefinirSenhaUsecase,
  }) : super(AuthInitial()) {
    on<AuthEmailSubmitted>(_onEmailSubmitted);
    on<AuthPinSubmitted>(_onPinSubmitted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthCadastrarSenhaRequested>(_onCadastrarSenhaRequested);
    on<AuthEsqueciSenhaRequested>(_onEsqueciSenhaRequested);
    on<AuthRedefinirSenhaPinSubmitted>(_onRedefinirSenhaPinSubmitted);
    on<AuthRedefinirSenhaRequested>(_onRedefinirSenhaRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthBackToEmailRequested>(_onBackToEmailRequested);
    on<AuthBackToSenhaRequested>(_onBackToSenhaRequested);
  }

  Future<void> _onEmailSubmitted(
    AuthEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await verificarEmailUsecase(event.email);
      if (result.precisaCadastroSenha) {
        emit(AuthPrimeiroAcesso(event.email));
      } else {
        emit(AuthEmailValidado(event.email));
      }
    } on Failure catch (e) {
      emit(AuthErro(e.message));
    }
  }

  Future<void> _onPinSubmitted(
    AuthPinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.pin.trim().isEmpty) {
      emit(AuthPrimeiroAcesso(
        event.email,
        erro: 'Informe o código PIN.',
      ));
      return;
    }
    emit(AuthLoading());
    try {
      await confirmarPinUsecase(email: event.email, pin: event.pin.trim());
      emit(AuthCadastroSenha(event.email));
    } on Failure catch (e) {
      emit(AuthPrimeiroAcesso(event.email, erro: e.message));
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
    } on Failure catch (e) {
      emit(AuthEmailValidado(event.email, erro: e.message));
    }
  }

  Future<void> _onEsqueciSenhaRequested(
    AuthEsqueciSenhaRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await enviarPinEmailUsecase(
        email: event.email,
        tipoToken: TipoToken.redefinirSenha,
      );
      emit(AuthRedefinirSenhaPin(event.email));
    } on Failure catch (e) {
      emit(AuthEmailValidado(event.email, erro: e.message));
    }
  }

  Future<void> _onRedefinirSenhaPinSubmitted(
    AuthRedefinirSenhaPinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.pin.trim().isEmpty) {
      emit(AuthRedefinirSenhaPin(
        event.email,
        erro: 'Informe o código PIN.',
      ));
      return;
    }
    emit(AuthLoading());
    try {
      await confirmarPinUsecase(
        email: event.email,
        pin: event.pin.trim(),
        tipoToken: TipoToken.redefinirSenha,
      );
      emit(AuthRedefinirSenhaNovaSenha(event.email));
    } on Failure catch (e) {
      emit(AuthRedefinirSenhaPin(event.email, erro: e.message));
    }
  }

  Future<void> _onRedefinirSenhaRequested(
    AuthRedefinirSenhaRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.senha != event.confirmacaoSenha) {
      emit(AuthRedefinirSenhaNovaSenha(
        event.email,
        erro: 'As senhas não coincidem.',
      ));
      return;
    }
    if (event.senha.length < 6) {
      emit(AuthRedefinirSenhaNovaSenha(
        event.email,
        erro: 'A senha deve ter no mínimo 6 caracteres.',
      ));
      return;
    }
    emit(AuthLoading());
    try {
      await redefinirSenhaUsecase(senha: event.senha);
      final usuario = await loginUsecase(
        email: event.email,
        senha: event.senha,
      );
      emit(AuthAutenticado(usuario));
    } on Failure catch (e) {
      emit(AuthRedefinirSenhaNovaSenha(event.email, erro: e.message));
    }
  }

  Future<void> _onCadastrarSenhaRequested(
    AuthCadastrarSenhaRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.senha != event.confirmacaoSenha) {
      emit(AuthCadastroSenha(
        event.email,
        erro: 'As senhas não coincidem.',
      ));
      return;
    }
    if (event.senha.length < 6) {
      emit(AuthCadastroSenha(
        event.email,
        erro: 'A senha deve ter no mínimo 6 caracteres.',
      ));
      return;
    }
    emit(AuthLoading());
    try {
      await signUpUsecase(senha: event.senha);
      final usuario = await loginUsecase(
        email: event.email,
        senha: event.senha,
      );
      emit(AuthAutenticado(usuario));
    } on Failure catch (e) {
      emit(AuthCadastroSenha(event.email, erro: e.message));
    }
  }

  void _onBackToEmailRequested(
    AuthBackToEmailRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUsecase();
    emit(AuthInitial());
  }

  void _onBackToSenhaRequested(
    AuthBackToSenhaRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthEmailValidado(event.email));
  }
}
