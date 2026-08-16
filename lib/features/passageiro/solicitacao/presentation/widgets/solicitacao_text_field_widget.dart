import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/widgets/app_colors.dart';
import 'solicitacao_input_widget.dart';

/// Campo de texto editável dos formulários de solicitação.
///
/// A moldura (borda, raio e sombra) é desenhada por este widget, então o
/// `InputDecorationTheme` global do app é anulado por completo — sem isso o
/// `TextField` desenharia a própria borda por dentro, criando o efeito de um
/// input dentro do outro.
class SolicitacaoTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final double height;

  /// Cor de destaque da borda quando o campo está em foco.
  final Color accentColor;

  const SolicitacaoTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.textInputAction,
    this.height = 45,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  State<SolicitacaoTextFieldWidget> createState() =>
      _SolicitacaoTextFieldWidgetState();
}

class _SolicitacaoTextFieldWidgetState
    extends State<SolicitacaoTextFieldWidget> {
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
    super.dispose();
  }

  void _aoMudarFoco() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final emFoco = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: widget.height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          cursorColor: widget.accentColor,
          cursorWidth: 1.6,
          style: const TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            counterText: '',
            hintStyle: const TextStyle(
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w400,
              color: AppColors.textGrey,
            ),
            // Anula por completo a moldura vinda do tema global.
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
