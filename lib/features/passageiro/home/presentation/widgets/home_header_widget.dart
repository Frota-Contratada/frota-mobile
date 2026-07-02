import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';

class HomeHeaderWidget extends StatelessWidget {
  final Usuario? usuario;
  final VoidCallback? onConfiguracoes;

  const HomeHeaderWidget({
    super.key,
    this.usuario,
    this.onConfiguracoes,
  });

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.nome ?? 'Maria Julia';
    final unidade = 'Unidade Jaguapitã';

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/passageiro/avatar_placeholder.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 20,
                backgroundColor: PassageiroColors.primaryBlue,
                child: Text(
                  _iniciais(nome),
                  style: const TextStyle(
                    color: PassageiroColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
                    color: PassageiroColors.darkBlue,
                    letterSpacing: -0.16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unidade,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PassageiroColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onConfiguracoes,
            icon: const Icon(
              Icons.settings_outlined,
              color: PassageiroColors.textMediumGrey,
              size: 27,
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
