import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Botão primário padrão para solicitações (arredondado, azul).
class SolicitacaoPrimaryButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final double height;
  final double fontSize;

  const SolicitacaoPrimaryButtonWidget({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primaryBlue,
    this.foregroundColor = AppColors.white,
    this.width = 220,
    this.height = 52,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
            disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: foregroundColor,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
