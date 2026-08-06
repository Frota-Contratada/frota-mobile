import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import 'solicitar_viagem_revisao_page.dart';

/// Página de solicitação de viagem - Step 2.
/// Campos: centro de custos, veículo, viagem compartilhada.
class SolicitarViagemStep2Page extends StatefulWidget {
  final String origem;
  final String destino;
  final String data;
  final String horario;
  final String motivo;

  const SolicitarViagemStep2Page({
    super.key,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horario,
    required this.motivo,
  });

  @override
  State<SolicitarViagemStep2Page> createState() =>
      _SolicitarViagemStep2PageState();
}

class _SolicitarViagemStep2PageState extends State<SolicitarViagemStep2Page> {
  String? _centroCusto;
  String? _veiculo;
  bool? _viagemCompartilhada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Mapa com rota
          Container(
            height: 306,
            width: double.infinity,
            color: AppColors.weekSelectorBg,
            child: const Center(
              child: Icon(Icons.map_outlined, size: 64, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -19, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            AppAssets.iconVoltar,
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solicitar viagem',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Preencha os campos abaixo para prosseguir',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Táxi'),
                    const SizedBox(height: 28),

                    // 4. Custos
                    _buildSecaoLabel('4.', 'Custos'),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      valor: _centroCusto,
                      hint: 'selecione o(s) centro(s) de custos',
                      onTap: () => setState(() => _centroCusto = '3144 - Conta 4442'),
                      iconAsset: AppAssets.iconCusto,
                    ),
                    const SizedBox(height: 28),

                    // 5. Veículo
                    _buildSecaoLabel('5.', 'Veículo'),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      valor: _veiculo,
                      hint: 'selecione um veículo',
                      onTap: () => setState(() => _veiculo = 'moto'),
                      iconAsset: AppAssets.iconVeiculo,
                    ),
                    const SizedBox(height: 28),

                    // Viagem compartilhada
                    _buildViagemCompartilhada(),
                    const SizedBox(height: 40),

                    // Botão Avançar
                    _buildBotaoAvancar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoLabel(String numero, String label) {
    return Row(
      children: [
        Text(
          numero,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? valor,
    required String hint,
    required VoidCallback onTap,
    required String iconAsset,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGrey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: valor != null
                  ? _buildChipValor(valor)
                  : Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                      ),
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildChipValor(String valor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.weekSelectorBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                // Remove seleção
                if (valor == _centroCusto) {
                  setState(() => _centroCusto = null);
                } else if (valor == _veiculo) {
                  setState(() => _veiculo = null);
                }
              },
              child: const Icon(Icons.close, size: 14, color: AppColors.textMediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViagemCompartilhada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outro funcionário irá te acompanhar?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _RadioOption(
              label: 'Sim',
              selected: _viagemCompartilhada == true,
              onTap: () => setState(() => _viagemCompartilhada = true),
            ),
            const SizedBox(width: 32),
            _RadioOption(
              label: 'Não',
              selected: _viagemCompartilhada == false,
              onTap: () => setState(() => _viagemCompartilhada = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotaoAvancar() {
    final habilitado = _podeAvancar();
    return Center(
      child: SizedBox(
        width: 245,
        height: 60,
        child: ElevatedButton(
          onPressed: habilitado ? _avancar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Avançar',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  bool _podeAvancar() {
    return _centroCusto != null &&
        _veiculo != null &&
        _viagemCompartilhada != null;
  }

  void _avancar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitarViagemRevisaoPage(
          origem: widget.origem,
          destino: widget.destino,
          data: widget.data,
          horario: widget.horario,
          motivo: widget.motivo,
          centroCusto: _centroCusto!,
          veiculo: _veiculo!,
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.borderGrey,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.darkBlue : AppColors.textMediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
