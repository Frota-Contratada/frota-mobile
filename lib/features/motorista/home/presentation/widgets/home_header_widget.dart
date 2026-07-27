import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../../../core/widgets/home_header_widget.dart' as shared;

/// Header da home do motorista.
/// Delegação para o widget compartilhado [shared.HomeHeaderWidget].
class HomeHeaderWidget extends StatelessWidget {
  final Usuario? usuario;
  final VoidCallback? onConfiguracoes;

  const HomeHeaderWidget({super.key, this.usuario, this.onConfiguracoes});

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.nome ?? 'Motorista';

    return shared.HomeHeaderWidget(
      nome: nome,
      subtitulo: 'Moreira Transportes',
      onConfiguracoes: onConfiguracoes,
    );
  }
}
