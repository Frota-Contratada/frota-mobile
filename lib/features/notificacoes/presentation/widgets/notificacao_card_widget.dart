import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../domain/entities/notificacao.dart';

class NotificacaoCardWidget extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback? onTap;

  const NotificacaoCardWidget({
    super.key,
    required this.notificacao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '${notificacao.titulo}. ${notificacao.mensagem}',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: notificacao.naoLida ? AppColors.weekSelectorBg : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderGrey),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    notificacao.naoLida
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none_outlined,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notificacao.titulo,
                              style: TextStyle(
                                color: AppColors.darkBlue,
                                fontSize: 16,
                                fontWeight: notificacao.naoLida
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (notificacao.naoLida)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 5),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notificacao.mensagem,
                        style: const TextStyle(
                          color: AppColors.textMediumGrey,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatarData(notificacao.criadaEm),
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (notificacao.acao != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, top: 4),
                    child: Icon(Icons.chevron_right, color: AppColors.textGrey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} às $hora:$minuto';
  }
}
