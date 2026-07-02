import 'package:flutter/material.dart';
import 'corrida_colors.dart';

class CorridaMapaWidget extends StatelessWidget {
  const CorridaMapaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CorridaColors.borderGrey),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color(0x1A101828),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/corrida/mapa_trajeto.png',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.27, -0.37),
          ),
          Positioned(
            left: 9,
            bottom: 24,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: CorridaColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 33,
            child: Icon(
              Icons.location_on,
              color: CorridaColors.primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
