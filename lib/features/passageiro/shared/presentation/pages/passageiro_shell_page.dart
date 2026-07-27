import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../home/presentation/pages/home_page.dart';
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
          _PlaceholderTab(
            titulo: 'Solicitações',
            icone: Icons.event_available_outlined,
          ),
          PassageiroHomePage(usuario: widget.usuario),
          _PlaceholderTab(
            titulo: 'Perfil',
            icone: Icons.person_outline,
          ),
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

class _PlaceholderTab extends StatelessWidget {
  final String titulo;
  final IconData icone;

  const _PlaceholderTab({
    required this.titulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 48,
              color: PassageiroColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: PassageiroColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Em breve',
              style: TextStyle(
                fontSize: 14,
                color: PassageiroColors.textMediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
