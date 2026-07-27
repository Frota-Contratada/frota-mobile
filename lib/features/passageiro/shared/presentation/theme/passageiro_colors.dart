import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Cores do passageiro - delega para [AppColors] compartilhado.
/// Mantido para compatibilidade com imports existentes.
/// Cores específicas do passageiro (card viagem/objeto) ficam aqui.
class PassageiroColors {
  static const Color background = AppColors.background;
  static const Color darkBlue = AppColors.darkBlue;
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color buttonBlue = AppColors.buttonBlue;
  static const Color emAndamentoBlue = AppColors.emAndamentoBlue;
  static const Color accentGreen = AppColors.accentGreen;
  static const Color weekSelectorBg = AppColors.weekSelectorBg;
  static const Color textGrey = AppColors.textGrey;
  static const Color textMediumGrey = AppColors.textMediumGrey;
  static const Color borderGrey = AppColors.borderGrey;
  static const Color timelineGrey = AppColors.timelineGrey;
  static const Color white = AppColors.white;

  // Cores específicas do passageiro (cards de solicitação)
  static const Color viagemCardBg = Color(0xFFDEE5F8);
  static const Color objetoCardBg = Color(0xFFFFEEE7);
  static const Color cardTitleDark = Color(0xFF14181F);
  static const Color cardSubtitleGrey = Color(0xFF707072);
}
