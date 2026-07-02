import 'package:flutter/material.dart';
import '../../../auth/domain/entities/usuario.dart';
import 'viagens_colors.dart';

class ViagensHeaderWidget extends StatelessWidget {
  final Usuario? usuario;
  final VoidCallback? onConfiguracoes;

  const ViagensHeaderWidget({
    super.key,
    this.usuario,
    this.onConfiguracoes,
  });

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.nome ?? 'Motorista';

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: ViagensColors.primaryBlue,
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: ViagensColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $nome!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ViagensColors.darkBlue,
                    letterSpacing: -0.16,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Moreira Transportes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ViagensColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onConfiguracoes,
            icon: const Icon(
              Icons.settings_outlined,
              color: ViagensColors.textMediumGrey,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : 'M';
  }
}
