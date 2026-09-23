import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../widgets/solicitacao_dropdown_options_widget.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import 'solicitar_objeto_revisao_page.dart';

class SolicitarObjetoStep2Page extends StatefulWidget {
  final String origem;
  final String destino;
  final String data;
  final String horario;
  final List<String> centrosCusto;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const SolicitarObjetoStep2Page({
    super.key,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horario,
    required this.centrosCusto,
    this.origemPoint,
    this.destinoPoint,
  });

  @override
  State<SolicitarObjetoStep2Page> createState() =>
      _SolicitarObjetoStep2PageState();
}

class _SolicitarObjetoStep2PageState extends State<SolicitarObjetoStep2Page> {
  String? _objeto;
  String? _veiculo;
  bool _objetoExpandido = false;
  bool _veiculoExpandido = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CriarSolicitacaoBloc>().state.rascunho;
    _objeto = draft.motivoNome;
    _veiculo = draft.veiculoNome;
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
                    const SolicitacaoModalidadeChipWidget(
                      modalidade: 'Objetos',
                    ),
                    const SizedBox(height: 12),
                    _buildSectionTitle('4.', 'Objeto'),
                    const SizedBox(height: 8),
                    _buildObjetoField(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('5.', 'Transporte'),
                    const SizedBox(height: 8),
                    _buildVehicleField(),
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
                'Solicitar transporte de itens',
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

  Widget _buildField({
    required String iconAsset,
    required String label,
    required String? value,
    required VoidCallback onTap,
    bool isDropdown = false,
    bool isOpen = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 45,
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: isOpen ? AppColors.primaryBlue : AppColors.borderGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SolicitacaoInputWidget(
            label: label,
            valor: value,
            isDropdown: isDropdown,
            isOpen: isOpen,
            onTap: onTap,
          ),
        ),
      ],
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

  Widget _buildObjetoField() {
    final objetos = context
        .watch<CriarSolicitacaoBloc>()
        .state
        .catalogos
        .nomesObjetos;

    return _buildSelectField(
      isOpen: _objetoExpandido,
      options: objetos,
      selected: _objeto,
      onSelected: (value) => setState(() {
        _objeto = value;
        _objetoExpandido = false;
      }),
      field: _buildField(
        iconAsset: AppAssets.iconTransporteItens,
        label: 'qual objeto será transportado?',
        value: _objeto,
        isDropdown: true,
        isOpen: _objetoExpandido,
        onTap: () => setState(() {
          _objetoExpandido = !_objetoExpandido;
          _veiculoExpandido = false;
        }),
      ),
    );
  }

  Widget _buildVehicleField() {
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
      field: _buildField(
        iconAsset: AppAssets.iconVeiculo,
        label: 'selecione um veículo',
        value: _veiculo,
        isDropdown: true,
        isOpen: _veiculoExpandido,
        onTap: () => setState(() {
          _veiculoExpandido = !_veiculoExpandido;
          _objetoExpandido = false;
        }),
      ),
    );
  }

  bool _podeAvancar() => _objeto != null && _veiculo != null;

  void _avancar() {
    final bloc = context.read<CriarSolicitacaoBloc>();
    final draft = bloc.state.rascunho.copyWith(
      data: widget.data,
      horario: widget.horario,
      motivoNome: _objeto,
      veiculoNome: _veiculo,
      centrosCusto: List<String>.of(widget.centrosCusto),
      origemDescricao: widget.origem,
      origemPoint: widget.origemPoint,
      destinoDescricao: widget.destino,
      destinoPoint: widget.destinoPoint,
      objeto: true,
    );
    bloc.add(SolicitacaoRascunhoAtualizado(draft));
    bloc.add(SimulacaoSolicitada(draft.toRascunho()));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SolicitarObjetoRevisaoPage(
            origem: widget.origem,
            destino: widget.destino,
            data: widget.data,
            horario: widget.horario,
            centrosCusto: widget.centrosCusto,
            objeto: _objeto!,
            veiculo: _veiculo!,
            origemPoint: widget.origemPoint,
            destinoPoint: widget.destinoPoint,
          ),
        ),
      ),
    );
  }
}
