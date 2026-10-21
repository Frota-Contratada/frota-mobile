import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../maps/endereco_autocomplete_service.dart';
import '../maps/endereco_sugestao.dart';
import '../maps/map_point.dart';
import 'app_colors.dart';
import 'app_map_widget.dart';
import 'busca_barra_widget.dart';
import 'endereco_sugestoes_widget.dart';

const _intervaloBuscaSugestoes = Duration(milliseconds: 350);

/// Seleciona um ponto por toque no mapa ou por busca de endereço.
class MapPickerPage extends StatefulWidget {
  final String title;
  final MapPoint? initialPoint;
  final String? initialAddress;
  final MapSelectionKind selectionKind;

  const MapPickerPage({
    super.key,
    required this.title,
    this.initialPoint,
    this.initialAddress,
    this.selectionKind = MapSelectionKind.destination,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late final TextEditingController _addressController;
  MapPoint? _selectedPoint;
  String? _selectedAddress;
  bool _resolvingAddress = false;
  Timer? _debounceSugestoes;
  int _buscaSugestoesId = 0;
  List<EnderecoSugestao> _sugestoes = const [];
  bool _buscandoSugestoes = false;
  String? _mensagemSugestoes;

  bool get _mostrarSugestoes =>
      _sugestoes.isNotEmpty || _mensagemSugestoes != null;

  bool get _isOrigin => widget.selectionKind == MapSelectionKind.origin;

  String get _pointLabel => switch (widget.selectionKind) {
    MapSelectionKind.origin => 'origem',
    MapSelectionKind.stop => 'parada',
    MapSelectionKind.destination => 'destino',
  };

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _selectedPoint = widget.initialPoint;
    _selectedAddress = widget.initialAddress;
    if (_selectedPoint != null && _selectedAddress == null) {
      _resolveInitialAddress();
    }
  }

  @override
  void dispose() {
    _debounceSugestoes?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  void _agendarBuscaSugestoes(String texto) {
    _debounceSugestoes?.cancel();
    final busca = texto.trim();

    if (busca.length < BackendEnderecoAutocompleteService.tamanhoMinimoBusca) {
      _buscaSugestoesId++;
      _limparSugestoes();
      return;
    }

    setState(() => _buscandoSugestoes = true);
    _debounceSugestoes = Timer(
      _intervaloBuscaSugestoes,
      () => _buscarSugestoes(busca),
    );
  }

  Future<void> _buscarSugestoes(String busca) async {
    final buscaId = ++_buscaSugestoesId;

    try {
      final sugestoes = await enderecoAutocompleteService.buscarSugestoes(
        busca,
        proximoDe: widget.initialPoint,
      );
      if (!mounted || buscaId != _buscaSugestoesId) return;

      setState(() {
        _buscandoSugestoes = false;
        _sugestoes = sugestoes;
        _mensagemSugestoes = sugestoes.isEmpty
            ? 'Nenhum endereço encontrado. Tente detalhar a busca.'
            : null;
      });
    } on BuscaEnderecoIndisponivelException {
      if (!mounted || buscaId != _buscaSugestoesId) return;

      setState(() {
        _buscandoSugestoes = false;
        _sugestoes = const [];
        _mensagemSugestoes =
            'Não foi possível buscar sugestões agora. Toque na seta para buscar.';
      });
    }
  }

  void _limparSugestoes() {
    setState(() {
      _buscandoSugestoes = false;
      _sugestoes = const [];
      _mensagemSugestoes = null;
    });
  }

  void _selecionarSugestao(EnderecoSugestao sugestao) {
    _debounceSugestoes?.cancel();
    _buscaSugestoesId++;
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedPoint = sugestao.ponto;
      _selectedAddress = sugestao.descricao;
      _addressController.text = sugestao.descricao;
      _buscandoSugestoes = false;
      _sugestoes = const [];
      _mensagemSugestoes = null;
    });
  }

  Future<void> _resolveInitialAddress() async {
    final point = _selectedPoint;
    if (point == null) return;
    final address = await reverseGeocodeMapPoint(point);
    if (!mounted || address == null) return;
    setState(() {
      _selectedAddress = address;
      _addressController.text = address;
    });
  }

  Future<void> _selectPoint(MapPoint point) async {
    _debounceSugestoes?.cancel();
    _buscaSugestoesId++;
    setState(() {
      _buscandoSugestoes = false;
      _sugestoes = const [];
      _mensagemSugestoes = null;
      _selectedPoint = point;
      _selectedAddress = null;
      _addressController.clear();
      _resolvingAddress = true;
    });

    final address = await reverseGeocodeMapPoint(point);
    if (!mounted) return;
    final fallback =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    setState(() {
      _selectedAddress = address ?? fallback;
      _addressController.text = _selectedAddress!;
      _resolvingAddress = false;
    });
  }

  Future<void> _searchAddress() async {
    if (_resolvingAddress) return;
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      _showMessage('Digite um endereço para buscar.');
      return;
    }

    if (_sugestoes.isNotEmpty) {
      _selecionarSugestao(_sugestoes.first);
      return;
    }

    _debounceSugestoes?.cancel();
    _buscaSugestoesId++;
    _limparSugestoes();
    FocusScope.of(context).unfocus();
    setState(() => _resolvingAddress = true);
    try {
      final locations = await Geocoding().locationFromAddress(query);
      if (!mounted) return;
      if (locations.isEmpty) {
        _showMessage('Não encontramos esse endereço. Tente detalhar a busca.');
        setState(() => _resolvingAddress = false);
        return;
      }

      final location = locations.first;
      final point = MapPoint(location.latitude, location.longitude);
      setState(() {
        _selectedPoint = point;
        _selectedAddress = query;
        _addressController.text = query;
        _resolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _resolvingAddress = false);
      _showMessage('Não foi possível buscar o endereço agora.');
    }
  }

  Future<void> _confirm() async {
    if (_selectedPoint == null) {
      await _searchAddress();
    }
    final point = _selectedPoint;
    if (point == null || !mounted) return;

    final address = _selectedAddress ?? _addressController.text.trim();
    Navigator.of(context).pop(
      MapSelectionResult(
        point: point,
        address: address.isEmpty ? null : address,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 8),
            child: BuscaBarraWidget(
              controller: _addressController,
              hintText: 'Rua, número, cidade',
              onChanged: (texto) {
                setState(() {
                  if (_selectedPoint != null) {
                    _selectedPoint = null;
                    _selectedAddress = null;
                  }
                });
                _agendarBuscaSugestoes(texto);
              },
              onSubmitted: (_) => _searchAddress(),
              suffixIcon: _buscandoSugestoes
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : _addressController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      onPressed: () {
                        _debounceSugestoes?.cancel();
                        _buscaSugestoesId++;
                        setState(() {
                          _addressController.clear();
                          _selectedPoint = null;
                          _selectedAddress = null;
                          _buscandoSugestoes = false;
                          _sugestoes = const [];
                          _mensagemSugestoes = null;
                        });
                      },
                    ),
              onBotaoAcao: _searchAddress,
              iconeBotaoAcao: Icons.arrow_forward_rounded,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppMapWidget(
                    origin:
                        _isOrigin ||
                            widget.selectionKind == MapSelectionKind.stop
                        ? _selectedPoint
                        : null,
                    destination:
                        _isOrigin ||
                            widget.selectionKind == MapSelectionKind.stop
                        ? null
                        : _selectedPoint,
                    initialCenter: widget.initialPoint,
                    onTap: _selectPoint,
                  ),
                ),
                if (_mostrarSugestoes)
                  Positioned(
                    top: 0,
                    left: 25,
                    right: 25,
                    child: EnderecoSugestoesWidget(
                      sugestoes: _sugestoes,
                      mensagem: _mensagemSugestoes,
                      onSelecionar: _selecionarSugestao,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha a $_pointLabel',
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _resolvingAddress
                      ? 'Identificando endereço...'
                      : _selectedAddress ??
                            'Toque no mapa ou busque um endereço acima.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMediumGrey),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _resolvingAddress ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _selectedPoint == null
                          ? 'Buscar e confirmar'
                          : 'Confirmar $_pointLabel',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
