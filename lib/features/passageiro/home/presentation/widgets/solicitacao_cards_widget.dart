import 'package:flutter/material.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';

class SolicitacaoCardsWidget extends StatelessWidget {
  final VoidCallback? onViagem;
  final VoidCallback? onObjeto;

  const SolicitacaoCardsWidget({
    super.key,
    this.onViagem,
    this.onObjeto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: _SolicitacaoCard(
              titulo: 'Viagem',
              subtitulo: 'Solicite um táxi',
              corFundo: PassageiroColors.viagemCardBg,
              icone: Icons.directions_car_outlined,
              ilustracao: Icons.local_taxi_outlined,
              onTap: onViagem,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SolicitacaoCard(
              titulo: 'Objeto',
              subtitulo: 'Transporte um item',
              corFundo: PassageiroColors.objetoCardBg,
              icone: Icons.arrow_forward,
              ilustracao: Icons.inventory_2_outlined,
              onTap: onObjeto,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitacaoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color corFundo;
  final IconData icone;
  final IconData ilustracao;
  final VoidCallback? onTap;

  const _SolicitacaoCard({
    required this.titulo,
    required this.subtitulo,
    required this.corFundo,
    required this.icone,
    required this.ilustracao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: corFundo,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 100,
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  ilustracao,
                  size: 72,
                  color: PassageiroColors.darkBlue.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: PassageiroColors.cardTitleDark,
                        letterSpacing: 0.16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 10,
                        color: PassageiroColors.cardSubtitleGrey,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: PassageiroColors.darkBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icone,
                        size: 12,
                        color: PassageiroColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
