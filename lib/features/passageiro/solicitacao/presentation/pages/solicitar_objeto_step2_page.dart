import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../widgets/solicitacao_secao_header_widget.dart';
import 'solicitar_objeto_revisao_page.dart';

/// Página de transporte de itens - Step 2.
/// Campos: objeto a transportar, veículo.
class SolicitarObjetoStep2Page extends StatefulWidget {
  final String origem;
  final String destino;
  final String data;
  final String horario;
  final String centroCusto;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const SolicitarObjetoStep2Page({
    super.key,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horario,
    required this.centroCusto,
    this.origemPoint,
    this.destinoPoint,
  });

  @override
  State<SolicitarObjetoStep2Page> createState() => _SolicitarObjetoStep2PageState();
}

class _SolicitarObjetoStep2PageState extends State<SolicitarObjetoStep2Page> {
  String? _objeto;
  String? _veiculo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 306,
            width: double.infinity,
            child: MapRoutePreview(
              originAddress: widget.origem,
              destinationAddress: widget.destino,
              origin: widget.origemPoint,
              destination: widget.destinoPoint,
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

                    // Objeto
                    const SolicitacaoSecaoHeaderWidget(emoji: '📦', label: 'Objeto'),
                    const SizedBox(height: 16),
                    SolicitacaoInputWidget(
                      label: 'qual objeto será transportado?',
                      valor: _objeto,
                      onTap: () => setState(() => _objeto = 'documentos'),
                    ),
                    const SizedBox(height: 24),

                    // Transporte
                    const SolicitacaoSecaoHeaderWidget(emoji: '🚗', label: 'Transporte'),
                    const SizedBox(height: 16),
                    SolicitacaoInputWidget(
                      label: 'selecione um veículo',
                      valor: _veiculo,
                      isDropdown: true,
                      onTap: () => setState(() => _veiculo = 'moto'),
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

  bool _podeAvancar() => _objeto != null && _veiculo != null;

  void _avancar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitarObjetoRevisaoPage(
          origem: widget.origem,
          destino: widget.destino,
          data: widget.data,
          horario: widget.horario,
          centroCusto: widget.centroCusto,
          objeto: _objeto!,
          veiculo: _veiculo!,
          origemPoint: widget.origemPoint,
          destinoPoint: widget.destinoPoint,
        ),
      ),
    );
  }
}
