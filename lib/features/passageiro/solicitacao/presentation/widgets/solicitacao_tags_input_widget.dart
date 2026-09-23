import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/widgets/app_colors.dart';
import 'solicitacao_input_widget.dart';

/// Campo de digitação manual de códigos (ex.: centros de custo).
///
/// Não abre lista de opções. As tags já adicionadas ficam dentro da própria
/// caixa do campo, em linha com o cursor: o usuário digita o número, confirma
/// no teclado e o valor entra como tag removível logo antes do cursor.
class SolicitacaoTagsInputWidget extends StatefulWidget {
  /// Placeholder exibido enquanto não há nenhuma tag.
  final String label;

  /// Tags já adicionadas.
  final List<String> values;

  final ValueChanged<String> onAdded;
  final ValueChanged<int> onRemoved;

  /// Texto auxiliar exibido abaixo do campo.
  final String? helperText;

  /// Máximo de dígitos aceitos por código.
  final int maxLength;

  /// Cor de destaque da borda em foco e do texto das tags.
  final Color accentColor;

  const SolicitacaoTagsInputWidget({
    super.key,
    required this.label,
    required this.values,
    required this.onAdded,
    required this.onRemoved,
    this.helperText,
    this.maxLength = 12,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  State<SolicitacaoTagsInputWidget> createState() =>
      _SolicitacaoTagsInputWidgetState();
}

class _SolicitacaoTagsInputWidgetState
    extends State<SolicitacaoTagsInputWidget> {
  /// Largura mínima da área de digitação quando já existem tags.
  static const double _larguraMinimaEntrada = 64;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_aoMudarFoco);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_aoMudarFoco);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _aoMudarFoco() => setState(() {});

  String get _texto => _controller.text.trim();

  /// Confirma o texto digitado como tag. Códigos vazios ou repetidos são
  /// apenas descartados. [manterFoco] deixa o teclado aberto para o usuário
  /// emendar o próximo código.
  void _adicionar({bool manterFoco = true}) {
    final texto = _texto;
    if (texto.isNotEmpty && !widget.values.contains(texto)) {
      widget.onAdded(texto);
    }
    _controller.clear();
    setState(() {});
    if (manterFoco) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final emFoco = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _focusNode.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                SolicitacaoInputWidget.borderRadius,
              ),
              border: Border.all(
                color: emFoco ? widget.accentColor : AppColors.dropdownBorder,
                width: emFoco ? 1.4 : 1,
              ),
              boxShadow: emFoco
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0A101038),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var index = 0; index < widget.values.length; index++)
                    _TagChip(
                      label: widget.values[index],
                      accentColor: widget.accentColor,
                      onRemove: () => widget.onRemoved(index),
                    ),
                  _buildEntrada(constraints.maxWidth),
                ],
              ),
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.helperText!,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ),
      ],
    );
  }

  /// Sem tags, a entrada ocupa a linha inteira para caber o placeholder.
  /// Com tags, ela encolhe para o tamanho do que está sendo digitado e fica
  /// logo depois da última tag, quebrando para a linha seguinte se faltar
  /// espaço.
  Widget _buildEntrada(double larguraDisponivel) {
    if (widget.values.isEmpty) {
      return SizedBox(width: larguraDisponivel, child: _buildTextField());
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _larguraMinimaEntrada,
        maxWidth: larguraDisponivel,
      ),
      child: IntrinsicWidth(child: _buildTextField()),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      cursorColor: widget.accentColor,
      cursorWidth: 1.6,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _adicionar(),
      // Ao sair do campo, o que já estava digitado não se perde.
      onTapOutside: (_) {
        _adicionar(manterFoco: false);
        _focusNode.unfocus();
      },
      style: const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: AppColors.darkBlue,
      ),
      decoration: InputDecoration(
        // Com tags na linha, o placeholder sai de cena para o cursor ficar
        // encostado na última tag.
        hintText: widget.values.isEmpty ? widget.label : null,
        counterText: '',
        hintStyle: const TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w400,
          color: AppColors.textGrey,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onRemove;

  const _TagChip({
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
