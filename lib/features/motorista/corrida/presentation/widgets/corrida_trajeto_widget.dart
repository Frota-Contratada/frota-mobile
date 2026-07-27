import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import 'corrida_colors.dart';

class CorridaTrajetoWidget extends StatelessWidget {
  final String origem;
  final String destino;

  const CorridaTrajetoWidget({
    super.key,
    required this.origem,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 12,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: CorridaColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 35,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: CorridaColors.primaryBlue.withValues(alpha: 0.4),
              ),
              Image.asset(
                AppAssets.iconDestino,
                width: 9,
                height: 11,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCampo(label: 'Origem', valor: origem),
              const SizedBox(height: 16),
              _buildCampo(label: 'Destino', valor: destino),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampo({required String label, required String valor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: CorridaColors.textGrey,
            letterSpacing: -0.16,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: CorridaColors.darkBlue,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
