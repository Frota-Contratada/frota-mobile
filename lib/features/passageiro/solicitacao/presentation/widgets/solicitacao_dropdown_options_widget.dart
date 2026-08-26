import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';

/// Lista de opções exibida abaixo de um campo de seleção, sem overlay.
///
/// Visual: painel branco arredondado com sombra suave, item selecionado
/// destacado por uma "pílula" de fundo claro com texto na cor de destaque e
/// barra de rolagem visível quando há mais itens do que o painel comporta.
class SolicitacaoDropdownOptionsWidget extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;
  final List<String>? optionIcons;

  /// Quantos itens ficam visíveis antes de a lista rolar.
  final int maxVisibleItems;

  /// Cor de destaque do item selecionado.
  final Color accentColor;

  const SolicitacaoDropdownOptionsWidget({
    super.key,
    required this.options,
    required this.onSelected,
    this.selected,
    this.optionIcons,
    this.maxVisibleItems = 4,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  State<SolicitacaoDropdownOptionsWidget> createState() =>
      _SolicitacaoDropdownOptionsWidgetState();
}

class _SolicitacaoDropdownOptionsWidgetState
    extends State<SolicitacaoDropdownOptionsWidget> {
  static const double _itemHeight = 44;
  static const double _itemSpacing = 2;
  static const double _listPadding = 6;
  static const double _panelRadius = 14;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _rolavel => widget.options.length > widget.maxVisibleItems;

  double get _maxHeight =>
      widget.maxVisibleItems * (_itemHeight + _itemSpacing) +
      (_listPadding * 2);

  @override
  Widget build(BuildContext context) {
    final lista = ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      physics: _rolavel
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        _listPadding,
        _listPadding,
        _rolavel ? _listPadding + 6 : _listPadding,
        _listPadding,
      ),
      itemCount: widget.options.length,
      separatorBuilder: (_, _) => const SizedBox(height: _itemSpacing),
      itemBuilder: (_, index) => _buildOption(index),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_panelRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101038),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_panelRadius),
          side: const BorderSide(color: AppColors.dropdownBorder),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: _maxHeight),
          child: _rolavel
              ? RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(4),
                  thumbColor: AppColors.scrollThumb,
                  crossAxisMargin: 4,
                  mainAxisMargin: 6,
                  child: lista,
                )
              : lista,
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    final option = widget.options[index];
    final isSelected = widget.selected == option;
    final icons = widget.optionIcons;
    final temIcone = icons != null && index < icons.length;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => widget.onSelected(option),
        borderRadius: BorderRadius.circular(10),
        splashColor: widget.accentColor.withValues(alpha: 0.08),
        highlightColor: widget.accentColor.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: _itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectedOptionBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (temIcone) ...[
                Image.asset(
                  icons[index],
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  color: isSelected ? widget.accentColor : AppColors.textGrey,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    color: isSelected ? widget.accentColor : AppColors.darkBlue,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 17, color: widget.accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
