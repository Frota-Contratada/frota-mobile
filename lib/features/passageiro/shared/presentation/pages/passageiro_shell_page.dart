import 'package:flutter/material.dart';
import '../../../../../core/responsive/app_layout.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../perfil/presentation/pages/perfil_page.dart';
import '../../../solicitacoes/presentation/pages/solicitacoes_page.dart';
import '../enums/passageiro_nav_destino.dart';
import '../theme/passageiro_colors.dart';
import '../widgets/passageiro_bottom_bar.dart';
import '../widgets/passageiro_navigation_rail.dart';

class PassageiroShellPage extends StatefulWidget {
  final Usuario? usuario;
  final PassageiroNavDestino destinoInicial;

  const PassageiroShellPage({
    super.key,
    this.usuario,
    this.destinoInicial = PassageiroNavDestino.home,
  });

  @override
  State<PassageiroShellPage> createState() => _PassageiroShellPageState();
}

class _PassageiroShellPageState extends State<PassageiroShellPage> {
  late PassageiroNavDestino _destinoAtivo;

  @override
  void initState() {
    super.initState();
    _destinoAtivo = widget.destinoInicial;
  }

  void _selecionarDestino(PassageiroNavDestino destino) {
    setState(() => _destinoAtivo = destino);
  }

  @override
  Widget build(BuildContext context) {
    final navegacaoLateral = AppLayout.of(context).usaNavegacaoLateral;
    final paginas = IndexedStack(
      index: _destinoAtivo.index,
      children: [
        SolicitacoesPage(usuario: widget.usuario),
        PassageiroHomePage(usuario: widget.usuario),
        PassageiroPerfilPage(usuario: widget.usuario),
      ],
    );

    return Scaffold(
      backgroundColor: PassageiroColors.background,
      body: Row(
        children: [
          if (navegacaoLateral)
            PassageiroNavigationRail(
              destinoAtivo: _destinoAtivo,
              onDestinoSelecionado: _selecionarDestino,
            ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: navegacaoLateral,
              child: paginas,
            ),
          ),
        ],
      ),
      bottomNavigationBar: navegacaoLateral
          ? null
          : PassageiroBottomBar(
              destinoAtivo: _destinoAtivo,
              onDestinoSelecionado: _selecionarDestino,
            ),
    );
  }
}
