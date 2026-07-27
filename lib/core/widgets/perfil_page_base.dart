import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

/// Estrutura base compartilhada da página de perfil entre motorista e passageiro.
/// Inclui: avatar, nome, subtítulo, KPIs, histórico com busca e filtro, e timeline de cards.
class PerfilPageBase extends StatelessWidget {
  final String nome;
  final String subtitulo;
  final String? avatarAssetPath;
  final int viagensFinalizadas;
  final int transportesDeItens;
  final VoidCallback onVoltar;
  final String? buscaTexto;
  final ValueChanged<String>? onBuscaChanged;
  final VoidCallback? onFiltroTap;
  final List<Widget> historicoContent;

  const PerfilPageBase({
    super.key,
    required this.nome,
    required this.subtitulo,
    required this.viagensFinalizadas,
    required this.transportesDeItens,
    required this.onVoltar,
    this.avatarAssetPath,
    this.buscaTexto,
    this.onBuscaChanged,
    this.onFiltroTap,
    this.historicoContent = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _PerfilHeader(onVoltar: onVoltar),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _AvatarSection(
                      nome: nome,
                      subtitulo: subtitulo,
                      avatarAssetPath: avatarAssetPath,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Divider(color: AppColors.borderGrey, height: 1),
                    ),
                    const SizedBox(height: 16),
                    _KpiSection(
                      viagensFinalizadas: viagensFinalizadas,
                      transportesDeItens: transportesDeItens,
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Meu histórico',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.21,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BuscaFiltroSection(
                      buscaTexto: buscaTexto,
                      onBuscaChanged: onBuscaChanged,
                      onFiltroTap: onFiltroTap,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 16, 24),
                      child: Column(children: historicoContent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilHeader extends StatelessWidget {
  final VoidCallback onVoltar;

  const _PerfilHeader({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onVoltar,
            child: Image.asset(
              AppAssets.iconVoltar,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'Meu perfil',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String nome;
  final String subtitulo;
  final String? avatarAssetPath;

  const _AvatarSection({
    required this.nome,
    required this.subtitulo,
    this.avatarAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            nome,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
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
    );
  }

  Widget _buildAvatar() {
    if (avatarAssetPath != null) {
      return ClipOval(
        child: Image.asset(
          avatarAssetPath!,
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarFallback(),
        ),
      );
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return CircleAvatar(
      radius: 42,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        _iniciais(nome),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 24,
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

class _KpiSection extends StatelessWidget {
  final int viagensFinalizadas;
  final int transportesDeItens;

  const _KpiSection({
    required this.viagensFinalizadas,
    required this.transportesDeItens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _KpiItem(
                valor: viagensFinalizadas.toString().padLeft(2, '0'),
                label: 'Viagens finalizadas',
                bgColor: AppColors.kpiBlueBg,
                iconAsset: AppAssets.iconViagensFinalizadas,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.borderGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiItem(
                valor: transportesDeItens.toString().padLeft(2, '0'),
                label: 'Transportes de itens',
                bgColor: AppColors.kpiOrangeBg,
                iconAsset: AppAssets.iconTransporteItens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  final String valor;
  final String label;
  final Color bgColor;
  final String iconAsset;

  const _KpiItem({
    required this.valor,
    required this.label,
    required this.bgColor,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kpiTextGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuscaFiltroSection extends StatelessWidget {
  final String? buscaTexto;
  final ValueChanged<String>? onBuscaChanged;
  final VoidCallback? onFiltroTap;

  const _BuscaFiltroSection({
    this.buscaTexto,
    this.onBuscaChanged,
    this.onFiltroTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.searchShadow,
                    blurRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Image.asset(
                    AppAssets.iconBusca,
                    width: 21,
                    height: 21,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: onBuscaChanged,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por destino',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.inputPlaceholder,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: onFiltroTap,
            child: Image.asset(
              AppAssets.iconFiltro,
              width: 21,
              height: 14,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
