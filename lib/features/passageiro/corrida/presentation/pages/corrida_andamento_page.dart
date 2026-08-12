import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';

class CorridaAndamentoPage extends StatelessWidget {
  final String origem;
  final String destino;
  final int minutosAndamento;
  final bool motoristaPausado;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const CorridaAndamentoPage({
    super.key,
    required this.origem,
    required this.destino,
    this.minutosAndamento = 10,
    this.motoristaPausado = false,
    this.origemPoint,
    this.destinoPoint,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
              child: Row(
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
                  const Text(
                    'Corrida em andamento',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mapa em tempo real com a posição atual, rota e enquadramento.
            Expanded(
              child: MapRoutePreview(
                originAddress: origem,
                destinationAddress: destino,
                origin: origemPoint,
                destination: destinoPoint,
                showCurrentLocation: true,
              ),
            ),

            // Bottom info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 24, 25, 32),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trajeto
                  _buildTrajeto(),
                  const SizedBox(height: 20),
                  // Status bar
                  _buildStatusBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrajeto() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 25,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: AppColors.borderGrey,
              ),
              const Icon(Icons.location_on, size: 15, color: AppColors.primaryBlue),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Origem',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textGrey),
              ),
              Text(
                origem,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Destino',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textGrey),
              ),
              Text(
                destino,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.darkBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final texto = motoristaPausado
        ? 'Motorista está aguardando há $minutosAndamento minutos'
        : 'Corrida em andamento há $minutosAndamento minutos';

    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
