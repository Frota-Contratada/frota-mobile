import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../widgets/solicitacao_secao_header_widget.dart';
import 'solicitar_objeto_step2_page.dart';

/// Página de solicitação de transporte de itens - Step 1.
/// Campos: origem, destino, data, horário, centro de custos.
class SolicitarObjetoPage extends StatefulWidget {
  const SolicitarObjetoPage({super.key});

  @override
  State<SolicitarObjetoPage> createState() => _SolicitarObjetoPageState();
}

class _SolicitarObjetoPageState extends State<SolicitarObjetoPage> {
  String? _origem;
  String? _destino;
  String? _data;
  String? _horario;
  String? _centroCusto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            height: 185,
            width: double.infinity,
            color: AppColors.weekSelectorBg,
            child: const Center(
              child: Icon(Icons.map_outlined, size: 48, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -21, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const Expanded(
                          child: Text(
                            'Solicitar transporte de itens',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 45),
                      child: Text(
                        'Preencha os campos abaixo para prosseguir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMediumGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Objetos'),
                    const SizedBox(height: 24),

                    // Trajeto
                    const SolicitacaoSecaoHeaderWidget(emoji: '📍', label: 'Trajeto'),
                    const SizedBox(height: 16),
                    _buildTrajetoSection(),
                    const SizedBox(height: 24),

                    // Data e horário
                    const SolicitacaoSecaoHeaderWidget(emoji: '📅', label: 'Data e horário'),
                    const SizedBox(height: 16),
                    SolicitacaoInputWidget(
                      label: 'data',
                      valor: _data,
                      onTap: () => setState(() => _data = '17/03/2026'),
                    ),
                    const SizedBox(height: 12),
                    SolicitacaoInputWidget(
                      label: 'horário',
                      valor: _horario,
                      onTap: () => setState(() => _horario = '18h30'),
                    ),
                    const SizedBox(height: 24),

                    // Custos
                    const SolicitacaoSecaoHeaderWidget(emoji: '💰', label: 'Custos'),
                    const SizedBox(height: 16),
                    SolicitacaoInputWidget(
                      label: 'selecione o(s) centro(s) de custos',
                      valor: _centroCusto,
                      isDropdown: true,
                      onTap: () => setState(() => _centroCusto = '3144 - Conta 4442'),
                    ),
                    const SizedBox(height: 40),

                    SolicitacaoPrimaryButtonWidget(
                      label: 'Avançar',
                      onPressed: _podeAvancar() ? _avancar : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrajetoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Container(
                width: 11, height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue, shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2, height: 30,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.borderGrey,
              ),
              const Icon(Icons.location_on, size: 18, color: AppColors.primaryBlue),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              SolicitacaoInputWidget(
                label: 'origem', valor: _origem,
                onTap: () => setState(() => _origem = 'Rod PR-340 - km 2.5, Jaguapitã'),
              ),
              const SizedBox(height: 12),
              SolicitacaoInputWidget(
                label: 'destino', valor: _destino,
                onTap: () => setState(() => _destino = 'Aeroporto de Londrina'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _podeAvancar() {
    return _origem != null && _destino != null && _data != null && _horario != null && _centroCusto != null;
  }

  void _avancar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitarObjetoStep2Page(
          origem: _origem!,
          destino: _destino!,
          data: _data!,
          horario: _horario!,
          centroCusto: _centroCusto!,
        ),
      ),
    );
  }
}
