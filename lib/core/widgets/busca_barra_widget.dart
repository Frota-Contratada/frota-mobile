import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

class BuscaBarraWidget extends StatelessWidget {
  static const double altura = 40;

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final VoidCallback? onBotaoAcao;
  final IconData iconeBotaoAcao;

  const BuscaBarraWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.onBotaoAcao,
    this.iconeBotaoAcao = Icons.tune,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(150),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(
                    AppAssets.iconBusca,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    color: AppColors.textGrey,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      onTap: onTap,
                      readOnly: readOnly,
                      enabled: enabled,
                      showCursor: !readOnly,
                      enableInteractiveSelection: !readOnly,
                      textInputAction: onSubmitted != null
                          ? TextInputAction.search
                          : TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.inputPlaceholder,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  ?suffixIcon,
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          if (onBotaoAcao != null) ...[
            const SizedBox(width: 10),
            Material(
              color: AppColors.primaryBlue,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: enabled ? onBotaoAcao : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: altura,
                  height: altura,
                  child: Icon(iconeBotaoAcao, color: AppColors.white, size: 18),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
