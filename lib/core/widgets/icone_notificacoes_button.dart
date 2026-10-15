import 'package:flutter/material.dart';
import 'app_colors.dart';

class IconeNotificacoesButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const IconeNotificacoesButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notificações',
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.darkBlue,
            size: 24,
          ),
        ),
      ),
    );
  }
}
