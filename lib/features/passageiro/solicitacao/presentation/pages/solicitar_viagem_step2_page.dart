import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../widgets/solicitacao_dropdown_options_widget.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_centros_custo_picker_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../widgets/solicitacao_text_field_widget.dart';
import 'solicitar_viagem_revisao_page.dart';

class SolicitarViagemStep2Page extends StatefulWidget {
  final String origem;
  final String destino;
  final List<String> paradas;
  final String data;
  final String horario;
  final String motivo;
  final MapPoint? origemPoint;
  final List<MapPoint> paradaPoints;
  final MapPoint? destinoPoint;

  const SolicitarViagemStep2Page({
    super.key,
    required this.origem,
    required this.destino,
    this.paradas = const [],
    required this.data,
    required this.horario,
    required this.motivo,
    this.origemPoint,
    this.paradaPoints = const [],
    this.destinoPoint,
  });

  @override
  State<SolicitarViagemStep2Page> createState() =>
      _SolicitarViagemStep2PageState();
}

class _SolicitarViagemStep2PageState extends State<SolicitarViagemStep2Page> {
  final List<String> _centrosCusto = <String>[];
  String? _veiculo;
  bool _veiculoExpandido = false;
  bool? _viagemCompartilhada;
  final List<TextEditingController> _cpfAcompanhanteControllers = [];

  @override
  void initState() {
    super.initState();
    final draft = context.read<CriarSolicitacaoBloc>().state.rascunho;
    _centrosCusto.addAll(draft.centrosCusto);
    _veiculo = draft.veiculoNome;
    _viagemCompartilhada = draft.viagemCompartilhada;
    for (final cpf in draft.cpfsAcompanhantes) {
      _cpfAcompanhanteControllers.add(TextEditingController(text: cpf));
    }
  }

  @override
  void dispose() {
    _limparAcompanhantes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            height: 306,
            width: double.infinity,
            child: MapRoutePreview(
              originAddress: widget.origem,
              destinationAddress: widget.destino,
              origin: widget.origemPoint,
              viaPoints: widget.paradaPoints,
              destination: widget.destinoPoint,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -19, 0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 24, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Táxi'),
                    const SizedBox(height: 12),
                    _buildSectionTitle('4.', 'Custos'),
                    const SizedBox(height: 8),
                    _buildCentroCustoField(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('5.', 'Veículo'),
                    const SizedBox(height: 8),
                    _buildVehicleField(),
                    const SizedBox(height: 10),
                    _buildViagemCompartilhada(),
                    if (_viagemCompartilhada == true) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('6.', 'Viagem compartilhada'),
                      const SizedBox(height: 8),
                      _buildAcompanhantes(),
                    ],
                    const SizedBox(height: 28),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            AppAssets.iconVoltar,
            width: 27,
            height: 27,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitar viagem',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Preencha os campos abaixo para prosseguir',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String number, String label) {
    return Text(
      '$number $label',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildFieldRow({
    required String iconAsset,
    required Widget child,
    bool destacado = false,
    double iconHeight = 48,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: iconHeight,
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: destacado ? AppColors.primaryBlue : AppColors.borderGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
        ?trailing,
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required String iconAsset,
    required VoidCallback onTap,
    bool isOpen = false,
  }) {
    return _buildFieldRow(
      iconAsset: iconAsset,
      destacado: isOpen,
      child: SolicitacaoInputWidget(
        label: hint,
        valor: value,
        isDropdown: true,
        isOpen: isOpen,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSelectField({
    required Widget field,
    required bool isOpen,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      children: [
        field,
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: isOpen
              ? Padding(
                  padding: const EdgeInsets.only(left: 28, top: 8),
                  child: SolicitacaoDropdownOptionsWidget(
                    options: options,
                    selected: selected,
                    onSelected: onSelected,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildCentroCustoField() {
    final state = context.watch<CriarSolicitacaoBloc>().state;

    return _buildFieldRow(
      iconAsset: AppAssets.iconCusto,
      destacado: _centrosCusto.isNotEmpty,
      iconHeight: 48,
      child: SolicitacaoCentrosCustoPickerWidget(
        disponiveis: state.catalogos.centrosCustoSelecionaveis,
        selecionados: _centrosCusto,
        carregando: state.carregandoCatalogos,
        onAdicionado: (numero) => setState(() => _centrosCusto.add(numero)),
        onRemovido: (index) => setState(() => _centrosCusto.removeAt(index)),
      ),
    );
  }

  Widget _buildVehicleField() {
    // Os tipos vêm de GET /solicitacoes/tipos-veiculo.
    final veiculos = context
        .watch<CriarSolicitacaoBloc>()
        .state
        .catalogos
        .nomesTiposVeiculo;

    return _buildSelectField(
      isOpen: _veiculoExpandido,
      options: veiculos,
      selected: _veiculo,
      onSelected: (value) => setState(() {
        _veiculo = value;
        _veiculoExpandido = false;
      }),
      field: _buildDropdown(
        value: _veiculo,
        hint: 'selecione um veículo',
        iconAsset: AppAssets.iconVeiculo,
        isOpen: _veiculoExpandido,
        onTap: () => setState(() => _veiculoExpandido = !_veiculoExpandido),
      ),
    );
  }

  Widget _buildViagemCompartilhada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outro funcionário irá te acompanhar?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _RadioOption(
              label: 'Sim',
              selected: _viagemCompartilhada == true,
              onTap: () => _selecionarCompartilhada(true),
            ),
            const SizedBox(width: 22),
            _RadioOption(
              label: 'Não',
              selected: _viagemCompartilhada == false,
              onTap: () => _selecionarCompartilhada(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcompanhantes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _cpfAcompanhanteControllers.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == _cpfAcompanhanteControllers.length - 1 ? 0 : 8,
            ),
            child: _buildCpfInput(index),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _adicionarAcompanhante,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Adicionar acompanhante'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCpfInput(int index) {
    final reservaEspacoRemover = _cpfAcompanhanteControllers.length > 1;
    final podeRemover = index > 0;

    return _buildFieldRow(
      iconAsset: AppAssets.iconFuncionario,
      iconHeight: 45,
      destacado: _cpfAcompanhanteControllers[index].text.trim().isNotEmpty,
      child: SolicitacaoTextFieldWidget(
        controller: _cpfAcompanhanteControllers[index],
        hintText: 'CPF do ${index + 2}º passageiro',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        onChanged: (_) => setState(() {}),
      ),
      trailing: reservaEspacoRemover
          ? SizedBox(
              width: 34,
              height: 45,
              child: podeRemover
                  ? Center(child: _buildRemoverAcompanhante(index))
                  : null,
            )
          : null,
    );
  }

  Widget _buildRemoverAcompanhante(int index) {
    return Semantics(
      button: true,
      label: 'Remover acompanhante',
      child: Tooltip(
        message: 'Remover acompanhante',
        child: InkWell(
          onTap: () => _removerAcompanhante(index),
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.remove_circle_outline,
              size: 19,
              color: AppColors.textMediumGrey,
            ),
          ),
        ),
      ),
    );
  }

  void _selecionarCompartilhada(bool value) {
    setState(() {
      _viagemCompartilhada = value;
      if (value && _cpfAcompanhanteControllers.isEmpty) {
        _cpfAcompanhanteControllers.add(TextEditingController());
      } else if (!value) {
        _limparAcompanhantes();
      }
    });
  }

  void _adicionarAcompanhante() {
    setState(() {
      _cpfAcompanhanteControllers.add(TextEditingController());
    });
  }

  void _removerAcompanhante(int index) {
    setState(() {
      _cpfAcompanhanteControllers.removeAt(index).dispose();
    });
  }

  void _limparAcompanhantes() {
    for (final controller in _cpfAcompanhanteControllers) {
      controller.dispose();
    }
    _cpfAcompanhanteControllers.clear();
  }

  int? _capacidadeDoVeiculo() {
    if (_veiculo == null) return null;

    final catalogos = context.read<CriarSolicitacaoBloc>().state.catalogos;

    for (final tipo in catalogos.tiposVeiculo) {
      if (tipo.nome == _veiculo) return tipo.capacidadePassageiros;
    }

    return null;
  }

  String? _mensagemCapacidade() {
    final capacidade = _capacidadeDoVeiculo();
    if (capacidade == null) return null;

    final quantidadePassageiros =
        1 +
        _cpfAcompanhanteControllers
            .where((controller) => controller.text.trim().isNotEmpty)
            .length;

    if (quantidadePassageiros <= capacidade) return null;

    return 'O veículo $_veiculo comporta até $capacidade passageiros, '
        'mas a viagem tem $quantidadePassageiros passageiros.';
  }

  bool _podeAvancar() {
    final acompanhantesPreenchidos =
        _viagemCompartilhada != true ||
        (_cpfAcompanhanteControllers.isNotEmpty &&
            _cpfAcompanhanteControllers.every(
              (controller) => controller.text.trim().isNotEmpty,
            ));
    final acompanhantesValidos =
        _viagemCompartilhada != true ||
        _cpfAcompanhanteControllers.every(
          (controller) => RegExp(r'^\d{11}$').hasMatch(controller.text.trim()),
        );

    return _centrosCusto.isNotEmpty &&
        _veiculo != null &&
        _viagemCompartilhada != null &&
        acompanhantesPreenchidos &&
        acompanhantesValidos;
  }

  void _avancar() {
    final mensagemCapacidade = _mensagemCapacidade();
    if (mensagemCapacidade != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensagemCapacidade)));
      return;
    }

    final bloc = context.read<CriarSolicitacaoBloc>();
    final acompanhantes = _cpfAcompanhanteControllers
        .map((controller) => controller.text.trim())
        .where((cpf) => cpf.isNotEmpty)
        .toList(growable: false);
    final draft = bloc.state.rascunho.copyWith(
      data: widget.data,
      horario: widget.horario,
      motivoNome: widget.motivo,
      veiculoNome: _veiculo,
      centrosCusto: List<String>.of(_centrosCusto),
      cpfsAcompanhantes: acompanhantes,
      origemDescricao: widget.origem,
      origemPoint: widget.origemPoint,
      destinoDescricao: widget.destino,
      destinoPoint: widget.destinoPoint,
      paradasDescricao: List<String>.of(widget.paradas),
      paradaPoints: widget.paradaPoints
          .map<MapPoint?>((point) => point)
          .toList(),
      viagemCompartilhada: _viagemCompartilhada,
    );
    bloc.add(SolicitacaoRascunhoAtualizado(draft));
    bloc.add(SimulacaoSolicitada(draft.toRascunho()));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SolicitarViagemRevisaoPage(
            origem: widget.origem,
            destino: widget.destino,
            paradas: widget.paradas,
            data: widget.data,
            horario: widget.horario,
            motivo: widget.motivo,
            centrosCusto: List<String>.of(_centrosCusto),
            veiculo: _veiculo!,
            acompanhantes: acompanhantes,
            origemPoint: widget.origemPoint,
            paradaPoints: widget.paradaPoints,
            destinoPoint: widget.destinoPoint,
          ),
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.borderGrey,
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
