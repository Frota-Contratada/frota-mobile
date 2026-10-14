import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_colors.dart';
import '../../../auth/domain/enums/perfil_usuario.dart';
import '../../domain/entities/preferencias_notificacao.dart';
import '../bloc/preferencias_notificacao_bloc.dart';
import 'notificacao_preferencia_toggle.dart';

typedef CategoriaVisivel = ({CategoriaNotificacao categoria, String label});

List<CategoriaVisivel> categoriasVisiveis(PerfilUsuario perfil) {
  return switch (perfil) {
    PerfilUsuario.passageiro => const [
      (
        categoria: CategoriaNotificacao.lembreteViagem,
        label: 'Lembretes de viagem',
      ),
      (
        categoria: CategoriaNotificacao.corridaConfirmada,
        label: 'Solicitação confirmada como corrida',
      ),
      (
        categoria: CategoriaNotificacao.solicitacaoEncerrada,
        label: 'Solicitação reprovada, recusada ou cancelada',
      ),
      (
        categoria: CategoriaNotificacao.corridaCancelada,
        label: 'Corrida cancelada',
      ),
    ],
    PerfilUsuario.motorista => const [
      (
        categoria: CategoriaNotificacao.lembreteViagem,
        label: 'Corrida próxima do início',
      ),
      (
        categoria: CategoriaNotificacao.corridaConfirmada,
        label: 'Nova corrida atribuída',
      ),
      (
        categoria: CategoriaNotificacao.corridaCancelada,
        label: 'Corrida cancelada',
      ),
    ],
  };
}

class PreferenciasNotificacaoSection extends StatelessWidget {
  final PerfilUsuario perfil;
  final Color corAtiva;
  final Color corInativa;

  const PreferenciasNotificacaoSection({
    super.key,
    required this.perfil,
    required this.corAtiva,
    required this.corInativa,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha quais notificações deseja receber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textMediumGrey,
            ),
          ),
          const SizedBox(height: 20),
          BlocConsumer<
            PreferenciasNotificacaoBloc,
            PreferenciasNotificacaoState
          >(
            listenWhen: (anterior, atual) =>
                atual is PreferenciasNotificacaoCarregada &&
                atual.erroSalvamento != null &&
                (anterior is! PreferenciasNotificacaoCarregada ||
                    anterior.erroSalvamento?.sequencia !=
                        atual.erroSalvamento!.sequencia),
            listener: (context, state) {
              final erro = (state as PreferenciasNotificacaoCarregada)
                  .erroSalvamento!;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
            },
            builder: (context, state) => switch (state) {
              PreferenciasNotificacaoCarregada() => _buildToggles(
                context,
                state,
              ),
              PreferenciasNotificacaoErro() => _buildErro(context, state),
              _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggles(
    BuildContext context,
    PreferenciasNotificacaoCarregada state,
  ) {
    final bloc = context.read<PreferenciasNotificacaoBloc>();
    final preferencias = state.preferencias;

    return Column(
      children: [
        NotificacaoPreferenciaToggle(
          label: 'Notificações no celular',
          descricao:
              'Desligado, os avisos continuam na lista de notificações do app.',
          ativo: preferencias.pushAtivo,
          habilitado: !state.estaSalvando(
            PreferenciasNotificacaoCarregada.chavePush,
          ),
          corAtiva: corAtiva,
          corInativa: corInativa,
          onChanged: (valor) => bloc.add(PreferenciaPushAlterada(valor)),
        ),
        for (final item in categoriasVisiveis(perfil)) ...[
          const SizedBox(height: 15),
          NotificacaoPreferenciaToggle(
            label: item.label,
            ativo: preferencias.ativa(item.categoria),
            habilitado: !state.estaSalvando(item.categoria.codigo),
            corAtiva: corAtiva,
            corInativa: corInativa,
            onChanged: (valor) =>
                bloc.add(PreferenciaCategoriaAlterada(item.categoria, valor)),
          ),
        ],
      ],
    );
  }

  Widget _buildErro(BuildContext context, PreferenciasNotificacaoErro state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.semConexao ? 'Você está sem internet.' : state.mensagem,
          style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
        ),
        TextButton(
          onPressed: () => context.read<PreferenciasNotificacaoBloc>().add(
            const PreferenciasNotificacaoCarregadas(),
          ),
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}
