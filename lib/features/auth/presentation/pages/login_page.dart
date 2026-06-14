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
  final _novaSenhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
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
      return _PrimeiroAcessoForm(
        email: state.email,
        novaSenhaController: _novaSenhaController,
        confirmaSenhaController: _confirmaSenhaController,
      );
    }

    if (state is AuthEmailValidado) {
      return _SenhaForm(
        email: state.email,
        emailController: _emailController,
        senhaController: _senhaController,
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

// Caso usuario já tenha senha
class _SenhaForm extends StatelessWidget {
  final String email;
  final TextEditingController emailController;
  final TextEditingController senhaController;

  const _SenhaForm({
    required this.email,
    required this.emailController,
    required this.senhaController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errorMessage = state is AuthErro ? state.mensagem : null;

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
              errorText: errorMessage,
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

// Primeiro acesso
class _PrimeiroAcessoForm extends StatelessWidget {
  final String email;
  final TextEditingController novaSenhaController;
  final TextEditingController confirmaSenhaController;

  const _PrimeiroAcessoForm({
    required this.email,
    required this.novaSenhaController,
    required this.confirmaSenhaController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errorMessage = state is AuthErro ? state.mensagem : null;

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
              errorText:
                  errorMessage,
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
