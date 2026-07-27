import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

/// Header compartilhado entre as home pages de motorista e passageiro.
/// Exibe avatar, saudação, subtítulo (transportadora/unidade) e ícone de configurações.
class HomeHeaderWidget extends StatelessWidget {
  final String nome;
  final String subtitulo;
  final String? avatarAssetPath;
  final VoidCallback? onConfiguracoes;
  final VoidCallback? onAvatarTap;

  const HomeHeaderWidget({
    super.key,
    required this.nome,
    required this.subtitulo,
    this.avatarAssetPath,
    this.onConfiguracoes,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: _buildAvatar(),
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
                    color: AppColors.darkBlue,
                    letterSpacing: -0.16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onConfiguracoes,
            icon: Image.asset(
              AppAssets.iconConfig,
              width: 27,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarAssetPath != null) {
      return ClipOval(
        child: Image.asset(
          avatarAssetPath!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarFallback(),
        ),
      );
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        _iniciais(nome),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }
}
