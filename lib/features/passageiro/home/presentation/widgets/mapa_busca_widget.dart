import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';

class MapaBuscaWidget extends StatelessWidget {
  final VoidCallback? onBuscarLocal;

  const MapaBuscaWidget({super.key, this.onBuscarLocal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 185,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/passageiro/mapa_home.png',
                width: double.infinity,
                height: 185,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 185,
                  color: PassageiroColors.weekSelectorBg,
                  child: const Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: PassageiroColors.textMediumGrey,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              left: 0,
              right: 0,
              child: Material(
                color: PassageiroColors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onBuscarLocal,
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Image.asset(
                          AppAssets.iconDestino,
                          width: 21,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Buscar local',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: PassageiroColors.textMediumGrey.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
