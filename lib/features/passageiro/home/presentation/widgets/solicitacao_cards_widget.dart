import 'package:flutter/material.dart';
import '../../../shared/presentation/theme/passageiro_assets.dart';
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
              corTitulo: PassageiroColors.cardTitleDark,
              ilustracaoPath: PassageiroAssets.ilustracaoViagem,
              ilustracaoWidth: 106,
              ilustracaoHeight: 72,
              onTap: onViagem,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: _SolicitacaoCard(
              titulo: 'Objeto',
              subtitulo: 'Transporte um item',
              corFundo: PassageiroColors.objetoCardBg,
              corTitulo: PassageiroColors.darkBlue,
              ilustracaoPath: PassageiroAssets.ilustracaoObjeto,
              ilustracaoWidth: 91,
              ilustracaoHeight: 68,
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
  final Color corTitulo;
  final String ilustracaoPath;
  final double ilustracaoWidth;
  final double ilustracaoHeight;
  final VoidCallback? onTap;

  const _SolicitacaoCard({
    required this.titulo,
    required this.subtitulo,
    required this.corFundo,
    required this.corTitulo,
    required this.ilustracaoPath,
    required this.ilustracaoWidth,
    required this.ilustracaoHeight,
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
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  ilustracaoPath,
                  width: ilustracaoWidth,
                  height: ilustracaoHeight,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 9,
                top: 16,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: corTitulo,
                        letterSpacing: titulo == 'Objeto' ? 0.16 : 0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: PassageiroColors.cardSubtitleGrey,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 9,
                bottom: 12,
                child: Image.asset(
                  PassageiroAssets.setaAcao,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
