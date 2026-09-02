import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

/// Origem e destino com linha vertical ligando o ponto azul ao pin.
class OrigemDestinoTrajetoWidget extends StatelessWidget {
  final String origem;
  final String destino;
  final List<String> paradas;

  const OrigemDestinoTrajetoWidget({
    super.key,
    required this.origem,
    required this.destino,
    this.paradas = const [],
  });

  static const double _colunaIcone = 12;
  static const double _espessuraLinha = 1.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _colunaIcone,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: _linhaVertical()),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(label: 'Origem', valor: origem),
              ),
            ],
          ),
        ),
        for (var index = 0; index < paradas.length; index++) ...[
          Row(
            children: [
              SizedBox(width: _colunaIcone, height: 16, child: _linhaVertical()),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _colunaIcone,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      Expanded(child: _linhaVertical()),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _campo(
                    label: 'Parada ${index + 1}',
                    valor: paradas[index],
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: [
            SizedBox(width: _colunaIcone, height: 16, child: _linhaVertical()),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _colunaIcone,
              child: Column(
                children: [
                  SizedBox(height: 2, child: _linhaVertical()),
                  Image.asset(
                    AppAssets.iconDestino,
                    width: 12,
                    height: 15,
                    fit: BoxFit.contain,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _campo(label: 'Destino', valor: destino),
            ),
          ],
        ),
      ],
    );
  }

  Widget _linhaVertical() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(width: _espessuraLinha, color: AppColors.borderGrey),
      ],
    );
  }

  Widget _campo({required String label, required String valor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
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
            color: AppColors.darkBlue,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
