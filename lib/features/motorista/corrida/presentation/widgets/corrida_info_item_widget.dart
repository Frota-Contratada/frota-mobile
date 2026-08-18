import 'package:flutter/material.dart';
import 'corrida_colors.dart';

class CorridaInfoItemWidget extends StatelessWidget {
  final Widget icon;
  final String label;
  final String valor;

  const CorridaInfoItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 12, height: 18, child: Center(child: icon)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
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
          ),
        ),
      ],
    );
  }
}
