import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../maps/map_point.dart';
import 'app_colors.dart';
import 'app_map_widget.dart';

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
    _addressController.dispose();
    super.dispose();
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
    setState(() {
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
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      _showMessage('Digite um endereço para buscar.');
      return;
    }

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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) {
                      if (_selectedPoint != null) {
                        setState(() {
                          _selectedPoint = null;
                          _selectedAddress = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _searchAddress(),
                    decoration: InputDecoration(
                      labelText: 'Digite o endereço',
                      hintText: 'Rua, número, cidade',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _addressController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _addressController.clear();
                                  _selectedPoint = null;
                                  _selectedAddress = null;
                                });
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _resolvingAddress ? null : _searchAddress,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  tooltip: 'Buscar endereço',
                ),
              ],
            ),
          ),
          Expanded(
            child: AppMapWidget(
              origin: _isOrigin || widget.selectionKind == MapSelectionKind.stop
                  ? _selectedPoint
                  : null,
              destination:
                  _isOrigin || widget.selectionKind == MapSelectionKind.stop
                  ? null
                  : _selectedPoint,
              initialCenter: widget.initialPoint,
              onTap: _selectPoint,
              onCurrentLocation: () {
                // O mapa envia a localização atual por onTap.
              },
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
