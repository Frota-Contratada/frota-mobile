import 'dart:convert';

import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';
import 'busca_barra_widget.dart';

class PerfilPageBase extends StatelessWidget {
  static const double _espacamentoAbaixoDaLinha = 16;

  final String nome;
  final String subtitulo;
  final String? unidade;
  final String? avatarAssetPath;
  final String? avatarDataUrl;
  final int viagensFinalizadas;
  final int transportesDeItens;
  final VoidCallback onVoltar;
  final bool mostrarBotaoVoltar;
  final bool mostrarLinhaAbaixoDoHeader;
  final String? buscaTexto;
  final ValueChanged<String>? onBuscaChanged;
  final VoidCallback? onFiltroTap;
  final List<Widget> historicoContent;

  const PerfilPageBase({
    super.key,
    required this.nome,
    required this.subtitulo,
    this.unidade,
    required this.viagensFinalizadas,
    required this.transportesDeItens,
    required this.onVoltar,
    this.mostrarBotaoVoltar = true,
    this.mostrarLinhaAbaixoDoHeader = false,
    this.avatarAssetPath,
    this.avatarDataUrl,
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
            if (mostrarBotaoVoltar) ...[
              _PerfilHeader(onVoltar: onVoltar),
              if (mostrarLinhaAbaixoDoHeader)
                const Padding(
                  padding: EdgeInsets.fromLTRB(25, 15, 25, 0),
                  child: Divider(color: AppColors.borderGrey, height: 1),
                ),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _AvatarSection(
                      nome: nome,
                      subtitulo: subtitulo,
                      unidade: unidade,
                      avatarAssetPath: avatarAssetPath,
                      avatarDataUrl: avatarDataUrl,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Divider(color: AppColors.borderGrey, height: 1),
                    ),
                    const SizedBox(height: _espacamentoAbaixoDaLinha),
                    _KpiSection(
                      viagensFinalizadas: viagensFinalizadas,
                      transportesDeItens: transportesDeItens,
                    ),
                    const SizedBox(height: _espacamentoAbaixoDaLinha),
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
                    const SizedBox(height: _espacamentoAbaixoDaLinha),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: BuscaBarraWidget(
                        hintText: 'Buscar por destino',
                        onChanged: onBuscaChanged,
                        onBotaoAcao: onFiltroTap,
                      ),
                    ),
                    const SizedBox(height: _espacamentoAbaixoDaLinha),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
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
  final String? unidade;
  final String? avatarAssetPath;
  final String? avatarDataUrl;

  const _AvatarSection({
    required this.nome,
    required this.subtitulo,
    this.unidade,
    this.avatarAssetPath,
    this.avatarDataUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                if (unidade != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    unidade!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarDataUrl != null) {
      final separador = avatarDataUrl!.indexOf(',');
      if (separador >= 0) {
        try {
          final bytes = base64Decode(avatarDataUrl!.substring(separador + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildAvatarFallback(),
            ),
          );
        } on FormatException {
        }
      }
    }

    if (avatarAssetPath != null) {
      return ClipOval(
        child: Image.asset(
          avatarAssetPath!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildAvatarFallback(),
        ),
      );
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return CircleAvatar(
      radius: 32,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        _iniciais(nome),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
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
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _KpiItem(
                      valor: viagensFinalizadas.toString().padLeft(2, '0'),
                      label: 'Viagens finalizadas',
                      bgColor: AppColors.kpiBlueBg,
                      iconAsset: AppAssets.iconViagensFinalizadas,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _KpiItem(
                      valor: transportesDeItens.toString().padLeft(2, '0'),
                      label: 'Transportes de itens',
                      bgColor: AppColors.kpiOrangeBg,
                      iconAsset: AppAssets.iconTransporteItens,
                    ),
                  ),
                ),
              ],
            ),
            const Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Spacer(),
                  ColoredBox(
                    color: AppColors.borderGrey,
                    child: SizedBox(width: 1),
                  ),
                  Spacer(),
                ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.kpiTextGrey,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
