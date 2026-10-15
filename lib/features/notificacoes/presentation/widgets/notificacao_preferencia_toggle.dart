import 'package:flutter/material.dart';
import '../../../../core/widgets/app_colors.dart';

class NotificacaoPreferenciaToggle extends StatelessWidget {
  final String label;
  final String? descricao;
  final bool ativo;
  final bool habilitado;
  final Color corAtiva;
  final Color corInativa;
  final ValueChanged<bool> onChanged;

  const NotificacaoPreferenciaToggle({
    super.key,
    required this.label,
    required this.ativo,
    required this.corAtiva,
    required this.corInativa,
    required this.onChanged,
    this.descricao,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        toggled: ativo,
        enabled: habilitado,
        button: true,
        label: label,
        child: InkWell(
          onTap: habilitado ? () => onChanged(!ativo) : null,
          child: Opacity(
            opacity: habilitado ? 1 : 0.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _buildChave(),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildTextos()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChave() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ativo ? corAtiva : corInativa,
        borderRadius: BorderRadius.circular(30),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: ativo ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.darkBlue,
          ),
        ),
        if (descricao != null) ...[
          const SizedBox(height: 4),
          Text(
            descricao!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textMediumGrey,
            ),
          ),
        ],
      ],
    );
  }
}
