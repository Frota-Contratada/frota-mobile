import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../perfil/presentation/pages/perfil_page.dart';
import '../../../solicitacoes/presentation/pages/solicitacoes_page.dart';
import '../enums/passageiro_nav_destino.dart';
import '../theme/passageiro_colors.dart';
import '../widgets/passageiro_bottom_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PassageiroColors.background,
      body: IndexedStack(
        index: _destinoAtivo.index,
        children: [
          SolicitacoesPage(usuario: widget.usuario),
          PassageiroHomePage(usuario: widget.usuario),
          PassageiroPerfilPage(usuario: widget.usuario),
        ],
      ),
      bottomNavigationBar: PassageiroBottomBar(
        destinoAtivo: _destinoAtivo,
        onDestinoSelecionado: (destino) {
          setState(() => _destinoAtivo = destino);
        },
      ),
    );
  }
}
