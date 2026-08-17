import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';
import '../../domain/entities/centro_custo.dart';
import 'solicitacao_dropdown_options_widget.dart';
import 'solicitacao_input_widget.dart';

class SolicitacaoCentrosCustoPickerWidget extends StatefulWidget {
  final List<CentroCusto> disponiveis;
  final List<String> selecionados;
  final ValueChanged<String> onAdicionado;
  final ValueChanged<int> onRemovido;
  final bool carregando;
  final Color accentColor;

  const SolicitacaoCentrosCustoPickerWidget({
    super.key,
    required this.disponiveis,
    required this.selecionados,
    required this.onAdicionado,
    required this.onRemovido,
    this.carregando = false,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  State<SolicitacaoCentrosCustoPickerWidget> createState() =>
      _SolicitacaoCentrosCustoPickerWidgetState();
}

class _SolicitacaoCentrosCustoPickerWidgetState
    extends State<SolicitacaoCentrosCustoPickerWidget> {
  bool _aberto = false;

  List<CentroCusto> get _naoSelecionados => widget.disponiveis
      .where(
        (centro) => !widget.selecionados.contains(centro.numero.toString()),
      )
      .toList();

  String _descricaoPorNumero(String numero) {
    for (final centro in widget.disponiveis) {
      if (centro.numero.toString() == numero) return centro.descricao;
    }

    return numero;
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = _naoSelecionados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selecionados.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var index = 0; index < widget.selecionados.length; index++)
                _Chip(
                  label: _descricaoPorNumero(widget.selecionados[index]),
                  accentColor: widget.accentColor,
                  onRemove: () => widget.onRemovido(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SolicitacaoInputWidget(
          label: widget.carregando
              ? 'carregando centros de custo...'
              : 'selecione o centro de custo',
          valor: null,
          isDropdown: true,
          isOpen: _aberto,
          onTap: widget.carregando || opcoes.isEmpty
              ? null
              : () => setState(() => _aberto = !_aberto),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _aberto && opcoes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SolicitacaoDropdownOptionsWidget(
                    options: opcoes
                        .map((centro) => centro.descricao)
                        .toList(),
                    onSelected: (descricao) {
                      final escolhido = opcoes.firstWhere(
                        (centro) => centro.descricao == descricao,
                      );

                      setState(() => _aberto = false);
                      widget.onAdicionado(escolhido.numero.toString());
                    },
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        if (!widget.carregando && widget.disponiveis.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Nenhum centro de custo com aprovador disponível na sua filial.',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onRemove;

  const _Chip({
    required this.label,
    required this.accentColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: AppColors.selectedOptionBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 5),
          Semantics(
            button: true,
            label: 'Remover $label',
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.cancel,
                size: 15,
                color: accentColor.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
