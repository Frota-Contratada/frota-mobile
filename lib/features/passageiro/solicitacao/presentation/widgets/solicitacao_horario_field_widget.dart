import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/widgets/app_colors.dart';
import 'solicitacao_text_field_widget.dart';

class SolicitacaoHorarioFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const SolicitacaoHorarioFieldWidget({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Semantics(
      textField: true,
      label: 'Horário da solicitação',
      hint: 'Digite o horário no formato horas e minutos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SolicitacaoTextFieldWidget(
            controller: controller,
            hintText: 'horário (HH:mm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [_HorarioInputFormatter()],
            onChanged: onChanged,
            textInputAction: TextInputAction.done,
            height: 48,
            accentColor: hasError ? Colors.red.shade700 : AppColors.primaryBlue,
          ),
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              label: 'Erro: $errorText',
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  errorText!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HorarioInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.end < 0
        ? 0
        : newValue.selection.end > newValue.text.length
        ? newValue.text.length
        : newValue.selection.end;
    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits = digits.length > 4 ? digits.substring(0, 4) : digits;
    final formatted = limitedDigits.length > 2
        ? '${limitedDigits.substring(0, 2)}:${limitedDigits.substring(2)}'
        : limitedDigits;
    final desiredCursor = digitsBeforeCursor > 2
        ? digitsBeforeCursor + 1
        : digitsBeforeCursor;
    final selectionOffset = desiredCursor > formatted.length
        ? formatted.length
        : desiredCursor;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
      composing: TextRange.empty,
    );
  }
}
