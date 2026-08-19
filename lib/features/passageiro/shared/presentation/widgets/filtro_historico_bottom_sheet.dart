import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/historico_filtro.dart';

class FiltroStatusOpcao {
  final String codigo;
  final String label;

  const FiltroStatusOpcao({required this.codigo, required this.label});
}

/// Bottom sheet compartilhado para filtros de solicitações e históricos.
///
/// O modal sempre sobe pela parte inferior, possui conteúdo rolável e devolve
/// o filtro somente quando o usuário aplica ou limpa as opções.
class FiltroHistoricoBottomSheet extends StatefulWidget {
  final HistoricoFiltro inicial;
  final bool mostrarStatus;
  final List<FiltroStatusOpcao> statusOpcoes;
  final String titulo;

  const FiltroHistoricoBottomSheet({
    super.key,
    this.inicial = const HistoricoFiltro(),
    this.mostrarStatus = false,
    this.statusOpcoes = const [],
    this.titulo = 'Filtrar registros no histórico',
  });

  @override
  State<FiltroHistoricoBottomSheet> createState() =>
      _FiltroHistoricoBottomSheetState();

  static Future<HistoricoFiltro?> show(
    BuildContext context, {
    HistoricoFiltro inicial = const HistoricoFiltro(),
    bool mostrarStatus = false,
    List<FiltroStatusOpcao> statusOpcoes = const [],
    String titulo = 'Filtrar registros no histórico',
  }) {
    return showModalBottomSheet<HistoricoFiltro>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltroHistoricoBottomSheet(
        inicial: inicial,
        mostrarStatus: mostrarStatus,
        statusOpcoes: statusOpcoes,
        titulo: titulo,
      ),
    );
  }
}

class _FiltroHistoricoBottomSheetState
    extends State<FiltroHistoricoBottomSheet> {
  late HistoricoOrdenacao _ordenacao;
  late HistoricoTipo _tipo;
  late HistoricoPeriodo _periodo;
  late String? _statusCodigo;

  @override
  void initState() {
    super.initState();
    _ordenacao = widget.inicial.ordenacao;
    _tipo = widget.inicial.tipo;
    _periodo = widget.inicial.periodo;
    _statusCodigo = widget.inicial.statusCodigo;
  }

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.sizeOf(context).height * .84;

    return Material(
      color: AppColors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 24, 25, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 24),
              _tituloSecao('Ordenar por'),
              const SizedBox(height: 12),
              _buildChipGroup(
                options: const [
                  _FiltroOpcao<HistoricoOrdenacao>(
                    label: 'Mais recente',
                    value: HistoricoOrdenacao.maisRecente,
                  ),
                  _FiltroOpcao<HistoricoOrdenacao>(
                    label: 'Mais antiga',
                    value: HistoricoOrdenacao.maisAntiga,
                  ),
                ],
                selected: _ordenacao,
                onSelected: (valor) => setState(() => _ordenacao = valor),
              ),
              const SizedBox(height: 24),
              _tituloSecao('Tipo de corrida'),
              const SizedBox(height: 12),
              _buildChipGroup(
                options: const [
                  _FiltroOpcao<HistoricoTipo>(
                    label: 'Viagem',
                    value: HistoricoTipo.viagem,
                  ),
                  _FiltroOpcao<HistoricoTipo>(
                    label: 'Transporte de itens',
                    value: HistoricoTipo.transporteItens,
                  ),
                ],
                selected: _tipo,
                onSelected: (valor) => setState(
                  () => _tipo = _tipo == valor ? HistoricoTipo.todos : valor,
                ),
              ),
              if (widget.mostrarStatus && widget.statusOpcoes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _tituloSecao('Status'),
                const SizedBox(height: 12),
                _buildStatusChips(),
              ],
              const SizedBox(height: 24),
              _tituloSecao('Período'),
              const SizedBox(height: 12),
              _buildChipGroup(
                options: const [
                  _FiltroOpcao<HistoricoPeriodo>(
                    label: 'Hoje',
                    value: HistoricoPeriodo.hoje,
                  ),
                  _FiltroOpcao<HistoricoPeriodo>(
                    label: 'Ontem',
                    value: HistoricoPeriodo.ontem,
                  ),
                  _FiltroOpcao<HistoricoPeriodo>(
                    label: 'Últimos 7 dias',
                    value: HistoricoPeriodo.ultimos7,
                  ),
                  _FiltroOpcao<HistoricoPeriodo>(
                    label: 'Últimos 15 dias',
                    value: HistoricoPeriodo.ultimos15,
                  ),
                  _FiltroOpcao<HistoricoPeriodo>(
                    label: 'Últimos 30 dias',
                    value: HistoricoPeriodo.ultimos30,
                  ),
                ],
                selected: _periodo,
                onSelected: (valor) => setState(
                  () => _periodo = _periodo == valor
                      ? HistoricoPeriodo.todos
                      : valor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    HistoricoFiltro(
                      ordenacao: _ordenacao,
                      tipo: _tipo,
                      periodo: _periodo,
                      statusCodigo: _statusCodigo,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const HistoricoFiltro()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMediumGrey,
                  ),
                  child: const Text(
                    'Limpar filtros',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) => Text(
    texto,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.darkBlue,
    ),
  );

  Widget _buildStatusChips() {
    return _buildChipGroup(
      options: [
        const _FiltroOpcao<String>(label: 'Todos', value: ''),
        ...widget.statusOpcoes.map(
          (status) =>
              _FiltroOpcao<String>(label: status.label, value: status.codigo),
        ),
      ],
      selected: _statusCodigo ?? '',
      onSelected: (valor) =>
          setState(() => _statusCodigo = valor.isEmpty ? null : valor),
    );
  }

  Widget _buildChipGroup<T>({
    required List<_FiltroOpcao<T>> options,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = option.value == selected;
        return GestureDetector(
          onTap: () => onSelected(option.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlue,
              ),
            ),
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.primaryBlue,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FiltroOpcao<T> {
  final String label;
  final T value;

  const _FiltroOpcao({required this.label, required this.value});
}
