import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/map_picker_page.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import 'solicitar_viagem_step2_page.dart';

/// Página de solicitação de viagem (Táxi) - Step 1.
/// Campos: origem, destino, data, horário, motivo.
class SolicitarViagemPage extends StatefulWidget {
  const SolicitarViagemPage({super.key});

  @override
  State<SolicitarViagemPage> createState() => _SolicitarViagemPageState();
}

class _SolicitarViagemPageState extends State<SolicitarViagemPage> {
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horarioController = TextEditingController();
  MapPoint? _origemPoint;
  MapPoint? _destinoPoint;
  String? _motivo;

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _dataController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 189,
            width: double.infinity,
            child: AppMapWidget(
              showAttribution: false,
              initialCenter: _origemPoint ?? _destinoPoint,
              origin: _origemPoint,
              destination: _destinoPoint,
            ),
          ),
          // Conteúdo
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -21, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            AppAssets.iconVoltar,
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solicitar viagem',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Preencha os campos abaixo para prosseguir',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Táxi'),
                    const SizedBox(height: 28),

                    // 1. Trajeto
                    _buildSecaoLabel('1.', 'Trajeto'),
                    const SizedBox(height: 14),
                    _buildTrajetoSection(),
                    const SizedBox(height: 28),

                    // 2. Data e horário de partida
                    _buildSecaoLabel('2.', 'Data e horário de partida'),
                    const SizedBox(height: 14),
                    _buildInputComIcone(
                      controller: _dataController,
                      hint: 'data',
                      iconAsset: AppAssets.iconData,
                      iconWidth: 14,
                      iconHeight: 16,
                      onTap: () => _selecionarData(),
                    ),
                    const SizedBox(height: 12),
                    _buildInputComIcone(
                      controller: _horarioController,
                      hint: 'horário',
                      iconAsset: AppAssets.iconHorario,
                      iconWidth: 14,
                      iconHeight: 14,
                      onTap: () => _selecionarHorario(),
                    ),
                    const SizedBox(height: 28),

                    // 3. Motivo da corrida
                    _buildSecaoLabel('3.', 'Motivo da corrida'),
                    const SizedBox(height: 14),
                    _buildDropdownMotivo(),
                    const SizedBox(height: 40),

                    // Botão Avançar
                    _buildBotaoAvancar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoLabel(String numero, String label) {
    return Row(
      children: [
        Text(
          numero,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTrajetoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicadores visuais
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: AppColors.borderGrey,
              ),
              Image.asset(
                AppAssets.iconDestino,
                width: 11,
                height: 14,
                fit: BoxFit.contain,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Inputs
        Expanded(
          child: Column(
            children: [
              _buildTextInput(
                controller: _origemController,
                hint: 'origem',
                onTap: () => _selecionarPonto(MapSelectionKind.origin),
              ),
              const SizedBox(height: 12),
              _buildTextInput(
                controller: _destinoController,
                hint: 'destino',
                onTap: () => _selecionarPonto(MapSelectionKind.destination),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Botão adicionar parada
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: () {
              // TODO: adicionar parada
            },
            child: Container(
              width: 31,
              height: 31,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBlue,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildInputComIcone({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    required double iconWidth,
    required double iconHeight,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Image.asset(
              iconAsset,
              width: iconWidth,
              height: iconHeight,
              fit: BoxFit.contain,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: controller.text.isEmpty ? FontWeight.w400 : FontWeight.w500,
                  color: controller.text.isEmpty ? AppColors.textGrey : AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMotivo() {
    return GestureDetector(
      onTap: _selecionarMotivo,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGrey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _motivo ?? 'descreva o motivo da corrida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _motivo != null ? FontWeight.w500 : FontWeight.w400,
                  color: _motivo != null ? AppColors.darkBlue : AppColors.textGrey,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoAvancar() {
    final habilitado = _podeAvancar();
    return Center(
      child: SizedBox(
        width: 245,
        height: 60,
        child: ElevatedButton(
          onPressed: habilitado ? _avancar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Avançar',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  bool _podeAvancar() {
    return _origemController.text.isNotEmpty &&
        _destinoController.text.isNotEmpty &&
        _dataController.text.isNotEmpty &&
        _horarioController.text.isNotEmpty &&
        _motivo != null;
  }

  Future<void> _selecionarPonto(MapSelectionKind kind) async {
    final atual = kind == MapSelectionKind.origin ? _origemPoint : _destinoPoint;
    final result = await Navigator.push<MapSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: kind == MapSelectionKind.origin ? 'Selecionar origem' : 'Selecionar destino',
          initialPoint: atual,
          selectionKind: kind,
        ),
      ),
    );
    if (!mounted || result == null) return;
    final address = result.address ??
        '${result.point.latitude.toStringAsFixed(5)}, ${result.point.longitude.toStringAsFixed(5)}';
    setState(() {
      if (kind == MapSelectionKind.origin) {
        _origemPoint = result.point;
        _origemController.text = address;
      } else {
        _destinoPoint = result.point;
        _destinoController.text = address;
      }
    });
  }

  void _selecionarData() {
    setState(() => _dataController.text = '17/03/2026');
  }

  void _selecionarHorario() {
    setState(() => _horarioController.text = '18h30');
  }

  void _selecionarMotivo() {
    setState(() => _motivo = 'Viagem de trabalho');
  }

  void _avancar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitarViagemStep2Page(
          origem: _origemController.text,
          destino: _destinoController.text,
          data: _dataController.text,
          horario: _horarioController.text,
          motivo: _motivo!,
          origemPoint: _origemPoint,
          destinoPoint: _destinoPoint,
        ),
      ),
    );
  }
}
