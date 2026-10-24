import 'package:flutter/material.dart';

import '../maps/endereco_sugestao.dart';
import 'app_colors.dart';

class EnderecoSugestoesWidget extends StatelessWidget {
  final List<EnderecoSugestao> sugestoes;
  final String? mensagem;
  final ValueChanged<EnderecoSugestao> onSelecionar;

  const EnderecoSugestoesWidget({
    super.key,
    required this.sugestoes,
    required this.onSelecionar,
    this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: mensagem != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                mensagem!,
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: sugestoes.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.borderGrey),
                itemBuilder: (context, index) {
                  final sugestao = sugestoes[index];

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    title: Text(
                      sugestao.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    subtitle: sugestao.subtitulo.isEmpty
                        ? null
                        : Text(
                            sugestao.subtitulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                    onTap: () => onSelecionar(sugestao),
                  );
                },
              ),
            ),
    );
  }
}
