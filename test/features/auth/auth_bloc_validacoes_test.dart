import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/auth/domain/entities/usuario.dart';
import 'package:frota_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:frota_mobile/features/auth/domain/usecases/confirmar_pin_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/enviar_pin_email_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/redefinir_senha_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:frota_mobile/features/auth/domain/usecases/verificar_email_usecase.dart';
import 'package:frota_mobile/features/auth/presentation/bloc/auth.bloc.dart';

class _AuthRepositoryEspiao implements AuthRepository {
  final chamadas = <String>[];

  @override
  Future<void> signUp({required String senha}) async {
    chamadas.add('signUp');
  }

  @override
  Future<Usuario> login({required String email, required String senha}) async {
    chamadas.add('login');
    return Usuario(nome: 'Teste', email: email);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    chamadas.add(invocation.memberName.toString());
    return super.noSuchMethod(invocation);
  }
}

AuthBloc _criarBloc(AuthRepository repository) => AuthBloc(
  verificarEmailUsecase: VerificarEmailUsecase(repository),
  loginUsecase: LoginUsecase(repository),
  signUpUsecase: SignUpUsecase(repository),
  logoutUsecase: LogoutUsecase(repository),
  confirmarPinUsecase: ConfirmarPinUsecase(repository),
  enviarPinEmailUsecase: EnviarPinEmailUsecase(repository),
  redefinirSenhaUsecase: RedefinirSenhaUsecase(repository),
);

Future<AuthState> _proximoEstado(AuthBloc bloc, AuthEvent evento) {
  final estado = bloc.stream.first;
  bloc.add(evento);
  return estado.timeout(const Duration(seconds: 2));
}

void main() {
  late _AuthRepositoryEspiao repository;
  late AuthBloc bloc;

  setUp(() {
    repository = _AuthRepositoryEspiao();
    bloc = _criarBloc(repository);
  });

  tearDown(() => bloc.close());

  test('primeiro acesso rejeita confirmação diferente da senha', () async {
    final estado = await _proximoEstado(
      bloc,
      const AuthCadastrarSenhaRequested(
        email: 'novo@empresa.com',
        senha: 'senha123',
        confirmacaoSenha: 'senha321',
      ),
    );

    expect(
      estado,
      const AuthCadastroSenha(
        'novo@empresa.com',
        erro: 'As senhas não coincidem.',
      ),
    );
    expect(repository.chamadas, isEmpty);
  });

  test('primeiro acesso rejeita senha com menos de 6 caracteres', () async {
    final estado = await _proximoEstado(
      bloc,
      const AuthCadastrarSenhaRequested(
        email: 'novo@empresa.com',
        senha: '123',
        confirmacaoSenha: '123',
      ),
    );

    expect(
      estado,
      const AuthCadastroSenha(
        'novo@empresa.com',
        erro: 'A senha deve ter no mínimo 6 caracteres.',
      ),
    );
    expect(repository.chamadas, isEmpty);
  });

  test('primeiro acesso cadastra a senha e autentica quando válida', () async {
    final estados = <AuthState>[];
    final assinatura = bloc.stream.listen(estados.add);

    bloc.add(
      const AuthCadastrarSenhaRequested(
        email: 'novo@empresa.com',
        senha: 'senha123',
        confirmacaoSenha: 'senha123',
      ),
    );
    await bloc.stream.firstWhere((estado) => estado is AuthAutenticado);
    await assinatura.cancel();

    expect(estados.first, isA<AuthLoading>());
    expect(repository.chamadas, ['signUp', 'login']);
  });

  test('login exige e-mail antes de chamar a API', () async {
    final estado = await _proximoEstado(bloc, const AuthEmailSubmitted(''));

    expect(estado, const AuthErro('Informe o e-mail.'));
    expect(repository.chamadas, isEmpty);
  });

  test('login rejeita e-mail com formato inválido', () async {
    final estado = await _proximoEstado(
      bloc,
      const AuthEmailSubmitted('email-invalido'),
    );

    expect(estado, const AuthErro('Informe um e-mail válido.'));
    expect(repository.chamadas, isEmpty);
  });

  test('login exige senha antes de chamar a API', () async {
    final estado = await _proximoEstado(
      bloc,
      const AuthLoginRequested(email: 'user@empresa.com', senha: ''),
    );

    expect(
      estado,
      const AuthEmailValidado('user@empresa.com', erro: 'Informe a senha.'),
    );
    expect(repository.chamadas, isEmpty);
  });
}
