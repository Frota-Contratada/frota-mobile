import 'package:flutter/material.dart';

import '../maps/map_point.dart';
import 'app_colors.dart';
import 'app_map_widget.dart';

class MapPickerPage extends StatefulWidget {
  final String title;
  final MapPoint? initialPoint;
  final MapSelectionKind selectionKind;

  const MapPickerPage({
    super.key,
    required this.title,
    this.initialPoint,
    this.selectionKind = MapSelectionKind.destination,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  MapPoint? _selectedPoint;
  String? _selectedAddress;
  bool _resolvingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
  }

  Future<void> _selectPoint(MapPoint point) async {
    setState(() {
      _selectedPoint = point;
      _selectedAddress = null;
      _resolvingAddress = true;
    });
    final address = await reverseGeocodeMapPoint(point);
    if (!mounted) return;
    setState(() {
      _selectedAddress = address;
      _resolvingAddress = false;
    });
  }

  void _confirm() {
    final point = _selectedPoint;
    if (point == null) return;
    Navigator.of(context).pop(
      MapSelectionResult(point: point, address: _selectedAddress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOrigin = widget.selectionKind == MapSelectionKind.origin;
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
          Expanded(
            child: AppMapWidget(
              origin: isOrigin ? _selectedPoint : null,
              destination: isOrigin ? null : _selectedPoint,
              initialCenter: widget.initialPoint,
              onTap: _selectPoint,
              onCurrentLocation: () {
                // The map already sends the current point through onTap.
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
                  isOrigin ? 'Toque no mapa para marcar a origem' : 'Toque no mapa para marcar o destino',
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
                      : _selectedAddress ?? 'Use o botão de localização para selecionar sua posição atual.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMediumGrey),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedPoint == null ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Confirmar local'),
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
