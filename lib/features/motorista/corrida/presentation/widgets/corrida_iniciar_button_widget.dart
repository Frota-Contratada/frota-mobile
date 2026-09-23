import 'package:flutter/material.dart';
import 'corrida_colors.dart';

class CorridaIniciarButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CorridaIniciarButtonWidget({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 83),
      child: Material(
        color: CorridaColors.accentGreen,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: CorridaColors.buttonText,
                      ),
                    )
                  : const Text(
                      'Iniciar corrida',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        color: CorridaColors.buttonText,
                        letterSpacing: -0.21,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
