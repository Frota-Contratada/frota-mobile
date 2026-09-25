import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/map_picker_page.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../utils/solicitacao_formatters.dart';
import '../widgets/solicitacao_dropdown_options_widget.dart';
import '../widgets/solicitacao_input_widget.dart';
import '../widgets/solicitacao_horario_field_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import 'solicitar_viagem_route_args.dart';
import 'solicitar_viagem_step2_page.dart';

class SolicitarViagemPage extends StatefulWidget {
  final SolicitarViagemRouteArgs? routeArgs;

  const SolicitarViagemPage({super.key, this.routeArgs});

  @override
  State<SolicitarViagemPage> createState() => _SolicitarViagemPageState();
}

class _SolicitarViagemPageState extends State<SolicitarViagemPage> {
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horarioController = TextEditingController();
  final List<TextEditingController> _paradaControllers = [];

  MapPoint? _origemPoint;
  MapPoint? _destinoPoint;
  final List<MapPoint?> _paradaPoints = [];
  DateTime? _dataSelecionada;
  String? _horarioErro;
  String? _motivo;
  bool _motivosExpandidos = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CriarSolicitacaoBloc>().state.rascunho;
    _origemController.text = draft.origemDescricao;
    _destinoController.text = draft.destinoDescricao;
    _dataController.text = draft.data;
    _horarioController.text = draft.horario;
    _origemPoint = draft.origemPoint;
    _destinoPoint = draft.destinoPoint;

    final destinoInicial = widget.routeArgs?.destinoInicial;
    if (destinoInicial != null) {
      _destinoController.text = _descricaoDoPonto(destinoInicial);
      _destinoPoint = destinoInicial.point;
    }

    _dataSelecionada = _parseData(draft.data);
    _horarioErro = _validarHorario(draft.horario, _dataSelecionada);
    _motivo = draft.motivoNome;

    final quantidadeParadas =
        draft.paradasDescricao.length > draft.paradaPoints.length
        ? draft.paradasDescricao.length
        : draft.paradaPoints.length;
    for (var index = 0; index < quantidadeParadas; index++) {
      _paradaControllers.add(
        TextEditingController(
          text: index < draft.paradasDescricao.length
              ? draft.paradasDescricao[index]
              : '',
        ),
      );
      _paradaPoints.add(
        index < draft.paradaPoints.length ? draft.paradaPoints[index] : null,
      );
    }
  }

  String _descricaoDoPonto(MapSelectionResult selection) {
    final address = selection.address?.trim();
    if (address != null && address.isNotEmpty) return address;

    return '${selection.point.latitude.toStringAsFixed(5)}, '
        '${selection.point.longitude.toStringAsFixed(5)}';
  }

  DateTime? _parseData(String value) => parseDataSolicitacao(value);

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _dataController.dispose();
    _horarioController.dispose();
    for (final controller in _paradaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;

        context.read<CriarSolicitacaoBloc>().add(
          const SolicitacaoRascunhoDescartado(),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            SizedBox(
              height: 189,
              width: double.infinity,
              child: AppMapWidget(
                showAttribution: false,
                origin: _origemPoint,
                viaPoints: _paradaPoints.whereType<MapPoint>().toList(),
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
                      _buildHeader(
                        title: 'Solicitar viagem',
                        subtitle: 'Preencha os campos abaixo para prosseguir',
                      ),
                      const SizedBox(height: 16),
                      SolicitacaoModalidadeChipWidget(
                        modalidade: _modalidadeLabel,
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('1.', 'Trajeto'),
                      const SizedBox(height: 8),
                      _buildTrajetoSection(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('2.', 'Data e horário de partida'),
                      const SizedBox(height: 8),
                      _buildIconInput(
                        iconAsset: AppAssets.iconData,
                        label: 'data',
                        value: _dataController.text,
                        onTap: _selecionarData,
                      ),
                      const SizedBox(height: 10),
                      _buildHorarioInput(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('3.', 'Motivo da corrida'),
                      const SizedBox(height: 8),
                      _buildMotivoInput(),
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
      ),
    );
  }

  String get _modalidadeLabel {
    final modalidade =
        widget.routeArgs?.modalidade ?? SolicitarViagemModalidade.taxi;

    return switch (modalidade) {
      SolicitarViagemModalidade.taxi => 'Táxi',
    };
  }

  Widget _buildHeader({required String title, required String subtitle}) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
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
        _buildRouteItem(
          label: 'origem',
          controller: _origemController,
          pointKind: MapSelectionKind.origin,
          point: _origemPoint,
        ),
        _buildRouteConnector(),
        for (var index = 0; index < _paradaControllers.length; index++) ...[
          _buildRouteItem(
            label: 'parada ${index + 1}',
            controller: _paradaControllers[index],
            pointKind: MapSelectionKind.stop,
            point: _paradaPoints[index],
            onRemove: () => _removerParada(index),
            onTap: () =>
                _selecionarPonto(MapSelectionKind.stop, stopIndex: index),
          ),
          _buildRouteConnector(),
        ],
        _buildRouteItem(
          label: 'destino',
          controller: _destinoController,
          pointKind: MapSelectionKind.destination,
          point: _destinoPoint,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _adicionarParada,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Adicionar parada'),
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

  Widget _buildRouteItem({
    required String label,
    required TextEditingController controller,
    required MapSelectionKind pointKind,
    required MapPoint? point,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    final selectPoint = onTap ?? () => _selecionarPonto(pointKind);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 45,
          child: Center(
            child: pointKind == MapSelectionKind.destination
                ? Image.asset(
                    AppAssets.iconDestinoCinza,
                    width: 16,
                    height: 18,
                    fit: BoxFit.contain,
                    color: point == null
                        ? AppColors.textGrey
                        : AppColors.primaryBlue,
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: point == null
                          ? AppColors.borderGrey
                          : AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRouteInput(
            controller: controller,
            label: label,
            onTap: selectPoint,
          ),
        ),
        if (onRemove != null)
          SizedBox(
            width: 28,
            height: 45,
            child: IconButton(
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.remove_circle_outline,
                size: 18,
                color: AppColors.textMediumGrey,
              ),
              tooltip: 'Remover $label',
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

  Widget _buildRouteInput({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    final value = controller.text.trim();
    return SolicitacaoInputWidget(
      label: label,
      valor: value.isEmpty ? null : value,
      onTap: onTap,
      height: 45,
    );
  }

  Widget _buildIconInput({
    required String iconAsset,
    required String label,
    required String? value,
    required VoidCallback onTap,
    bool isDropdown = false,
  }) {
    return Row(
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
              color: AppColors.borderGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SolicitacaoInputWidget(
            label: label,
            valor: value,
            isDropdown: isDropdown,
            onTap: onTap,
            height: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 48,
          child: Center(
            child: Image.asset(
              AppAssets.iconHorario,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: _horarioErro == null
                  ? AppColors.borderGrey
                  : Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SolicitacaoHorarioFieldWidget(
            controller: _horarioController,
            errorText: _horarioErro,
            onChanged: _aoAlterarHorario,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 48,
          child: Center(
            child: Image.asset(
              AppAssets.iconMotivo,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: _motivosExpandidos
                  ? AppColors.primaryBlue
                  : AppColors.borderGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              SolicitacaoInputWidget(
                label: 'descreva o motivo da corrida',
                valor: _motivo,
                isDropdown: true,
                isOpen: _motivosExpandidos,
                onTap: () =>
                    setState(() => _motivosExpandidos = !_motivosExpandidos),
                height: 48,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _motivosExpandidos
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildMotivoOptions(),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoOptions() {
    final state = context.watch<CriarSolicitacaoBloc>().state;
    final motivos = state.catalogos.nomesMotivosViagem;

    if (state.carregandoCatalogos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Carregando motivos...',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      );
    }

    if (state.erro != null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Não foi possível carregar os motivos.',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      );
    }

    if (motivos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum motivo disponível.',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      );
    }

    return SolicitacaoDropdownOptionsWidget(
      options: motivos,
      selected: _motivo,
      onSelected: _selecionarMotivo,
    );
  }

  bool _podeAvancar() {
    final temParadasValidas = _paradaControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
    final data = _dataSelecionada;
    final horario = parseHorarioSolicitacao(_horarioController.text);

    return _origemController.text.trim().isNotEmpty &&
        _destinoController.text.trim().isNotEmpty &&
        temParadasValidas &&
        data != null &&
        horario != null &&
        _horarioErro == null &&
        dataHoraSolicitacaoValida(data, horario) &&
        _motivo != null;
  }

  Future<void> _selecionarPonto(MapSelectionKind kind, {int? stopIndex}) async {
    final controller = switch (kind) {
      MapSelectionKind.origin => _origemController,
      MapSelectionKind.stop => _paradaControllers[stopIndex!],
      MapSelectionKind.destination => _destinoController,
    };
    final atual = switch (kind) {
      MapSelectionKind.origin => _origemPoint,
      MapSelectionKind.stop => _paradaPoints[stopIndex!],
      MapSelectionKind.destination => _destinoPoint,
    };

    final result = await Navigator.push<MapSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: switch (kind) {
            MapSelectionKind.origin => 'Selecionar origem',
            MapSelectionKind.stop => 'Adicionar parada',
            MapSelectionKind.destination => 'Selecionar destino',
          },
          initialPoint: atual,
          initialAddress: controller.text.trim().isEmpty
              ? null
              : controller.text.trim(),
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
      controller.text = address;
      switch (kind) {
        case MapSelectionKind.origin:
          _origemPoint = result.point;
        case MapSelectionKind.stop:
          _paradaPoints[stopIndex!] = result.point;
        case MapSelectionKind.destination:
          _destinoPoint = result.point;
      }
    });
  }

  void _adicionarParada() {
    setState(() {
      _paradaControllers.add(TextEditingController());
      _paradaPoints.add(null);
    });
  }

  void _removerParada(int index) {
    setState(() {
      _paradaControllers.removeAt(index).dispose();
      _paradaPoints.removeAt(index);
    });
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final dataInicial =
        _dataSelecionada != null &&
            !_dataSelecionada!.isBefore(
              DateTime(hoje.year, hoje.month, hoje.day),
            )
        ? _dataSelecionada!
        : hoje;
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 2, hoje.month, hoje.day),
      helpText: 'Selecione a data da viagem',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (!mounted || data == null) return;

    final horario = parseHorarioSolicitacao(_horarioController.text);
    final horarioInvalido =
        horario != null && !dataHoraSolicitacaoValida(data, horario);

    setState(() {
      _dataSelecionada = data;
      _dataController.text = formatarDataSolicitacao(data);
      if (horarioInvalido) {
        _horarioController.clear();
        _horarioErro = null;
      } else {
        _horarioErro = _validarHorario(_horarioController.text, data);
      }
    });

    if (horarioInvalido) _mostrarErroDataHora();
  }

  void _aoAlterarHorario(String value) {
    setState(() {
      _horarioErro = _validarHorario(value, _dataSelecionada);
    });
  }

  String? _validarHorario(String value, DateTime? data) {
    if (value.isEmpty || value.length < 5) return null;

    final horario = parseHorarioSolicitacao(value);
    if (horario == null) return 'Informe um horário entre 00:00 e 23:59.';

    final dataBase = data ?? DateTime.now();
    if (!dataHoraSolicitacaoValida(dataBase, horario)) {
      return 'A data e o horário da corrida devem estar no futuro.';
    }

    return null;
  }

  void _mostrarErroDataHora() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('A data e o horário da corrida devem estar no futuro.'),
        ),
      );
  }

  void _selecionarMotivo(String motivo) {
    setState(() {
      _motivo = motivo;
      _motivosExpandidos = false;
    });
  }

  void _avancar() {
    final bloc = context.read<CriarSolicitacaoBloc>();
    final draft = SolicitacaoDraft(
      data: _dataController.text,
      horario: _horarioController.text,
      motivoNome: _motivo,
      centrosCusto: bloc.state.rascunho.centrosCusto,
      origemDescricao: _origemController.text.trim(),
      origemPoint: _origemPoint,
      destinoDescricao: _destinoController.text.trim(),
      destinoPoint: _destinoPoint,
      paradasDescricao: [
        for (final controller in _paradaControllers) controller.text.trim(),
      ],
      paradaPoints: List<MapPoint?>.of(_paradaPoints),
    );
    bloc.add(SolicitacaoRascunhoAtualizado(draft));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SolicitarViagemStep2Page(
            origem: _origemController.text.trim(),
            destino: _destinoController.text.trim(),
            paradas: [
              for (final controller in _paradaControllers)
                controller.text.trim(),
            ],
            origemPoint: _origemPoint,
            paradaPoints: _paradaPoints.whereType<MapPoint>().toList(),
            destinoPoint: _destinoPoint,
            data: _dataController.text,
            horario: _horarioController.text,
            motivo: _motivo!,
          ),
        ),
      ),
    );
  }
}
