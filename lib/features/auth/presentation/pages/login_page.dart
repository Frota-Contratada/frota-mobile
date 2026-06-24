import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes.dart';
import '../bloc/auth.bloc.dart';
import '../widgets/auth_form_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _pinController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _pinController.dispose();
    _novaSenhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAutenticado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bem-vindo(a), ${state.usuario.nome}!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              const AuthHeaderGradient(),
              Column(
                children: [
                  const SizedBox(height: 220),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AuthBottomCard(
                        child: _buildContent(context, state),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    if (state is AuthPrimeiroAcesso) {
      return _PinForm(
        email: state.email,
        pinController: _pinController,
        errorMessage: state.erro,
      );
    }

    if (state is AuthCadastroSenha) {
      return _PrimeiroAcessoForm(
        email: state.email,
        novaSenhaController: _novaSenhaController,
        confirmaSenhaController: _confirmaSenhaController,
        errorMessage: state.erro,
      );
    }

    if (state is AuthRedefinirSenhaPin) {
      return _RedefinirSenhaPinForm(
        email: state.email,
        pinController: _pinController,
        errorMessage: state.erro,
      );
    }

    if (state is AuthRedefinirSenhaNovaSenha) {
      return _RedefinirSenhaForm(
        email: state.email,
        novaSenhaController: _novaSenhaController,
        confirmaSenhaController: _confirmaSenhaController,
        errorMessage: state.erro,
      );
    }

    if (state is AuthEmailValidado) {
      return _SenhaForm(
        email: state.email,
        emailController: _emailController,
        senhaController: _senhaController,
        errorMessage: state.erro,
      );
    }

    final errorMessage = state is AuthErro ? state.mensagem : null;
    final isLoading = state is AuthLoading;

    return _EmailForm(
      emailController: _emailController,
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
  }
}

class _EmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;

  const _EmailForm({
    required this.emailController,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthBrandTitle(),
        const SizedBox(height: 32),
        const Text(
          'Entre na sua conta',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AuthColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Preencha suas informações',
          style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 40),

        AppInput(
          label: 'E-mail',
          hintText: 'email@seara.com.br',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: errorMessage,
        ),

        const SizedBox(height: 40),
        AuthPrimaryButton(
          label: 'Avançar',
          isLoading: isLoading,
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isEmpty) return;
            context.read<AuthBloc>().add(AuthEmailSubmitted(email));
          },
        ),
      ],
    );
  }
}

// Login com senha cadastrada
class _SenhaForm extends StatelessWidget {
  final String email;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final String? errorMessage;

  const _SenhaForm({
    required this.email,
    required this.emailController,
    required this.senhaController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final erro = state is AuthEmailValidado
            ? state.erro ?? errorMessage
            : errorMessage;

        return Column(
          children: [
            const AuthBrandTitle(),
            const SizedBox(height: 32),
            const Text(
              'Entre na sua conta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preencha suas informações',
              style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            AppInput(
              label: 'E-mail',
              hintText: 'email@seara.com.br',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            const SizedBox(height: 20),

            AppInput(
              label: 'Senha',
              hintText: '********',
              controller: senhaController,
              isPassword: true,
              errorText: erro,
            ),

            const SizedBox(height: 40),
            AuthPrimaryButton(
              label: 'Entrar',
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthLoginRequested(email: email, senha: senhaController.text),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(
                        AuthEsqueciSenhaRequested(email),
                      );
                    },
              child: const Text(
                'Esqueci minha senha',
                style: TextStyle(color: AuthColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                emailController.clear();
                senhaController.clear();

                // Dispara o evento para voltar à tela inicial de e-mail
                context.read<AuthBloc>().add(AuthBackToEmailRequested());
              },
              child: const Text(
                'Usar outro e-mail',
                style: TextStyle(color: AuthColors.primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Primeiro acesso — confirmação do PIN enviado por e-mail
class _PinForm extends StatelessWidget {
  final String email;
  final TextEditingController pinController;
  final String? errorMessage;

  const _PinForm({
    required this.email,
    required this.pinController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final erro = state is AuthPrimeiroAcesso
            ? state.erro ?? errorMessage
            : errorMessage;

        return Column(
          children: [
            const AuthBrandTitle(),
            const SizedBox(height: 32),
            const Text(
              'Primeiro acesso',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite o código PIN enviado para o seu e-mail',
              style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AppInput(
              label: 'Código PIN',
              hintText: '000000',
              controller: pinController,
              keyboardType: TextInputType.number,
              errorText: erro,
            ),
            const SizedBox(height: 40),
            AuthPrimaryButton(
              label: 'Confirmar PIN',
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthPinSubmitted(
                    email: email,
                    pin: pinController.text,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                pinController.clear();
                context.read<AuthBloc>().add(AuthBackToEmailRequested());
              },
              child: const Text(
                'Usar outro e-mail',
                style: TextStyle(color: AuthColors.primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Primeiro acesso — cadastro de senha após PIN confirmado
class _PrimeiroAcessoForm extends StatelessWidget {
  final String email;
  final TextEditingController novaSenhaController;
  final TextEditingController confirmaSenhaController;
  final String? errorMessage;

  const _PrimeiroAcessoForm({
    required this.email,
    required this.novaSenhaController,
    required this.confirmaSenhaController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final erro = state is AuthCadastroSenha
            ? state.erro ?? errorMessage
            : errorMessage;

        return Column(
          children: [
            const AuthBrandTitle(),
            const SizedBox(height: 32),
            const Text(
              'Primeiro acesso',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre uma senha para acessar o aplicativo',
              style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            AppInput(
              label: 'Nova senha',
              hintText: '********',
              controller: novaSenhaController,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            AppInput(
              label: 'Confirme a senha',
              hintText: '********',
              controller: confirmaSenhaController,
              isPassword: true,
              errorText: erro,
            ),

            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mínimo de 6 caracteres',
                style: TextStyle(fontSize: 12, color: AuthColors.textGrey),
              ),
            ),
            const SizedBox(height: 40),
            AuthPrimaryButton(
              label: 'Cadastrar senha',
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthCadastrarSenhaRequested(
                    email: email,
                    senha: novaSenhaController.text,
                    confirmacaoSenha: confirmaSenhaController.text,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Redefinir senha — confirmação do PIN enviado por e-mail
class _RedefinirSenhaPinForm extends StatelessWidget {
  final String email;
  final TextEditingController pinController;
  final String? errorMessage;

  const _RedefinirSenhaPinForm({
    required this.email,
    required this.pinController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final erro = state is AuthRedefinirSenhaPin
            ? state.erro ?? errorMessage
            : errorMessage;

        return Column(
          children: [
            const AuthBrandTitle(),
            const SizedBox(height: 32),
            const Text(
              'Redefinir senha',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite o código PIN enviado para o seu e-mail',
              style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AppInput(
              label: 'Código PIN',
              hintText: '000000',
              controller: pinController,
              keyboardType: TextInputType.number,
              errorText: erro,
            ),
            const SizedBox(height: 40),
            AuthPrimaryButton(
              label: 'Confirmar PIN',
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthRedefinirSenhaPinSubmitted(
                    email: email,
                    pin: pinController.text,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                pinController.clear();
                context.read<AuthBloc>().add(AuthBackToSenhaRequested(email));
              },
              child: const Text(
                'Voltar para o login',
                style: TextStyle(color: AuthColors.primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Redefinir senha — nova senha após PIN confirmado
class _RedefinirSenhaForm extends StatelessWidget {
  final String email;
  final TextEditingController novaSenhaController;
  final TextEditingController confirmaSenhaController;
  final String? errorMessage;

  const _RedefinirSenhaForm({
    required this.email,
    required this.novaSenhaController,
    required this.confirmaSenhaController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final erro = state is AuthRedefinirSenhaNovaSenha
            ? state.erro ?? errorMessage
            : errorMessage;

        return Column(
          children: [
            const AuthBrandTitle(),
            const SizedBox(height: 32),
            const Text(
              'Redefinir senha',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre uma nova senha para acessar o aplicativo',
              style: TextStyle(color: AuthColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            AppInput(
              label: 'Nova senha',
              hintText: '********',
              controller: novaSenhaController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Confirme a senha',
              hintText: '********',
              controller: confirmaSenhaController,
              isPassword: true,
              errorText: erro,
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mínimo de 6 caracteres',
                style: TextStyle(fontSize: 12, color: AuthColors.textGrey),
              ),
            ),
            const SizedBox(height: 40),
            AuthPrimaryButton(
              label: 'Redefinir senha',
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthRedefinirSenhaRequested(
                    email: email,
                    senha: novaSenhaController.text,
                    confirmacaoSenha: confirmaSenhaController.text,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
