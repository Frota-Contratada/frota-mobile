import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/map_picker_page.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../utils/solicitacao_formatters.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_centros_custo_picker_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import 'solicitar_objeto_step2_page.dart';

class SolicitarObjetoPage extends StatefulWidget {
  const SolicitarObjetoPage({super.key});

  @override
  State<SolicitarObjetoPage> createState() => _SolicitarObjetoPageState();
}

class _SolicitarObjetoPageState extends State<SolicitarObjetoPage> {
  final List<String> _centrosCusto = <String>[];

  String? _origem;
  String? _destino;
  String? _data;
  String? _horario;
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;
  MapPoint? _origemPoint;
  MapPoint? _destinoPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            height: 185,
            width: double.infinity,
            child: AppMapWidget(
              showAttribution: false,
              origin: _origemPoint,
              destination: _destinoPoint,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -21, 0),
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
                    _buildSectionTitle('1.', 'Trajeto'),
                    const SizedBox(height: 8),
                    _buildTrajetoSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('2.', 'Data e horário'),
                    const SizedBox(height: 8),
                    _buildIconInput(
                      iconAsset: AppAssets.iconData,
                      label: 'data',
                      value: _data,
                      onTap: _selecionarData,
                    ),
                    const SizedBox(height: 10),
                    _buildIconInput(
                      iconAsset: AppAssets.iconHorario,
                      label: 'horário',
                      value: _horario,
                      onTap: _selecionarHorario,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('3.', 'Custos'),
                    const SizedBox(height: 8),
                    _buildCentroCustoField(),
                    const SizedBox(height: 30),
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

  Widget _buildTrajetoSection() {
    return Column(
      children: [
        _buildRoutePoint(
          label: 'origem',
          value: _origem,
          isDestination: false,
          onTap: () => _selecionarPonto(MapSelectionKind.origin),
        ),
        _buildRouteConnector(),
        _buildRoutePoint(
          label: 'destino',
          value: _destino,
          isDestination: true,
          onTap: () => _selecionarPonto(MapSelectionKind.destination),
        ),
      ],
    );
  }

  Widget _buildRoutePoint({
    required String label,
    required String? value,
    required bool isDestination,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 45,
          child: Center(
            child: isDestination
                ? Image.asset(
                    AppAssets.iconDestinoCinza,
                    width: 16,
                    height: 18,
                    fit: BoxFit.contain,
                    color: AppColors.textGrey,
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.borderGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SolicitacaoInputWidget(
            label: label,
            valor: value,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteConnector() {
    return SizedBox(
      height: 8,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Center(
              child: Container(
                width: 1,
                height: 8,
                color: AppColors.borderGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildIconInput({
    required String iconAsset,
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return _buildFieldRow(
      iconAsset: iconAsset,
      child: SolicitacaoInputWidget(
        label: label,
        valor: value,
        onTap: onTap,
        height: 48,
      ),
    );
  }

  Widget _buildFieldRow({
    required String iconAsset,
    required Widget child,
    bool destacado = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 48,
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
      ],
    );
  }

  Widget _buildCentroCustoField() {
    final state = context.watch<CriarSolicitacaoBloc>().state;

    return _buildFieldRow(
      iconAsset: AppAssets.iconCusto,
      destacado: _centrosCusto.isNotEmpty,
      child: SolicitacaoCentrosCustoPickerWidget(
        disponiveis: state.catalogos.centrosCustoSelecionaveis,
        selecionados: _centrosCusto,
        carregando: state.carregandoCatalogos,
        onAdicionado: (numero) => setState(() => _centrosCusto.add(numero)),
        onRemovido: (index) => setState(() => _centrosCusto.removeAt(index)),
      ),
    );
  }

  Future<void> _selecionarPonto(MapSelectionKind kind) async {
    final atual = kind == MapSelectionKind.origin
        ? _origemPoint
        : _destinoPoint;
    final result = await Navigator.push<MapSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: kind == MapSelectionKind.origin
              ? 'Selecionar origem'
              : 'Selecionar destino',
          initialPoint: atual,
          initialAddress: kind == MapSelectionKind.origin ? _origem : _destino,
          selectionKind: kind,
        ),
      ),
    );
    if (!mounted || result == null) return;
    final address =
        result.address ??
        '${result.point.latitude.toStringAsFixed(5)}, '
            '${result.point.longitude.toStringAsFixed(5)}';
    setState(() {
      if (kind == MapSelectionKind.origin) {
        _origemPoint = result.point;
        _origem = address;
      } else {
        _destinoPoint = result.point;
        _destino = address;
      }
    });
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate:
          _dataSelecionada != null &&
              !_dataSelecionada!.isBefore(
                DateTime(hoje.year, hoje.month, hoje.day),
              )
          ? _dataSelecionada!
          : hoje,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 2, hoje.month, hoje.day),
      helpText: 'Selecione a data do transporte',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (!mounted || data == null) return;
    setState(() {
      _dataSelecionada = data;
      _data = formatarDataSolicitacao(data);
    });
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
      helpText: 'Selecione o horário do transporte',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (!mounted || horario == null) return;
    final agora = DateTime.now();
    setState(() {
      _horarioSelecionado = horario;
      _horario = formatarHorarioSolicitacao(
        DateTime(
          agora.year,
          agora.month,
          agora.day,
          horario.hour,
          horario.minute,
        ),
      );
    });
  }

  bool _podeAvancar() {
    return _origem != null &&
        _destino != null &&
        _data != null &&
        _horario != null &&
        _centrosCusto.isNotEmpty;
  }

  void _avancar() {
    final bloc = context.read<CriarSolicitacaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SolicitarObjetoStep2Page(
            origem: _origem!,
            destino: _destino!,
            data: _data!,
            horario: _horario!,
            centrosCusto: List<String>.of(_centrosCusto),
            origemPoint: _origemPoint,
            destinoPoint: _destinoPoint,
          ),
        ),
      ),
    );
  }
}
