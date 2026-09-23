import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

/// Ícone de configurações alinhado à margem direita do conteúdo (25px),
/// sem o padding extra do [IconButton].
class IconeConfiguracoesButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const IconeConfiguracoesButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        AppAssets.iconConfig,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        color: AppColors.darkBlue,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
