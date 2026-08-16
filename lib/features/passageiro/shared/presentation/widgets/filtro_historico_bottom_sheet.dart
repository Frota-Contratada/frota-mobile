import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Bottom sheet de filtro para o histórico de corridas.
/// Permite filtrar por ordenação, tipo de corrida e período.
class FiltroHistoricoBottomSheet extends StatefulWidget {
  final VoidCallback? onAplicar;
  final VoidCallback? onLimpar;

  const FiltroHistoricoBottomSheet({
    super.key,
    this.onAplicar,
    this.onLimpar,
  });

  @override
  State<FiltroHistoricoBottomSheet> createState() => _FiltroHistoricoBottomSheetState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FiltroHistoricoBottomSheet(),
    );
  }
}

class _FiltroHistoricoBottomSheetState extends State<FiltroHistoricoBottomSheet> {
  String _ordenacao = 'Mais recente';
  String _tipoCorrida = 'Todas';
  DateTimeRange? _periodo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 24, 25, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar registros no histórico',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 24),

          // Ordenar por
          const Text(
            'Ordenar por',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 12),
          _buildChipGroup(
            options: ['Mais recente', 'Mais antiga'],
            selected: _ordenacao,
            onSelected: (v) => setState(() => _ordenacao = v),
          ),
          const SizedBox(height: 24),

          // Tipo de corrida
          const Text(
            'Tipo de corrida',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 12),
          _buildChipGroup(
            options: ['Todas', 'Viagem', 'Objeto'],
            selected: _tipoCorrida,
            onSelected: (v) => setState(() => _tipoCorrida = v),
          ),
          const SizedBox(height: 24),

          // Período
          const Text(
            'Período',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarPeriodo,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGrey),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _periodo != null
                          ? '${_formatDate(_periodo!.start)} - ${_formatDate(_periodo!.end)}'
                          : 'Selecione o período',
                      style: TextStyle(
                        fontSize: 16,
                        color: _periodo != null ? AppColors.darkBlue : AppColors.textGrey,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textGrey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botão aplicar
          Center(
            child: SizedBox(
              width: 245,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAplicar?.call();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Aplicar Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                widget.onLimpar?.call();
                Navigator.pop(context);
              },
              child: const Text(
                'Limpar filtros',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMediumGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.borderGrey,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.darkBlue,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selecionarPeriodo() async {
    final resultado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      locale: const Locale('pt', 'BR'),
    );
    if (resultado != null) {
      setState(() => _periodo = resultado);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
