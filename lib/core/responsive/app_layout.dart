import 'package:flutter/widgets.dart';

enum AppLayoutTipo { compacto, medio, expandido }

class AppLayout {
  static const double larguraMedia = 600;
  static const double larguraExpandida = 840;
  static const double larguraConteudo = 720;
  static const double larguraFormulario = 560;
  static const double alturaReferenciaCompacta = 800;

  final Size tamanho;

  const AppLayout(this.tamanho);

  factory AppLayout.of(BuildContext context) =>
      AppLayout(MediaQuery.sizeOf(context));

  double get largura => tamanho.width;
  double get altura => tamanho.height;

  AppLayoutTipo get tipo {
    if (largura >= larguraExpandida) return AppLayoutTipo.expandido;
    if (largura >= larguraMedia) return AppLayoutTipo.medio;
    return AppLayoutTipo.compacto;
  }

  bool get compacto => tipo == AppLayoutTipo.compacto;
  bool get paisagem => largura > altura;
  bool get usaPainelLateral => !compacto && paisagem;
  bool get usaNavegacaoLateral => usaPainelLateral;

  double get respiroLateral => compacto ? 0 : 8;

  double get larguraPainelLateral => (largura * 0.44).clamp(360.0, 480.0);

  double alturaProporcional(double alturaBase, {double fatorMaximo = 1.6}) {
    if (compacto) return alturaBase;
    final fator = (altura / alturaReferenciaCompacta).clamp(1.0, fatorMaximo);
    return alturaBase * fator;
  }

  static double margemCentralizada(
    double larguraDisponivel, {
    double margemMinima = 0,
    double larguraMaxima = larguraConteudo,
  }) {
    final sobra = (larguraDisponivel - larguraMaxima) / 2;
    return sobra > margemMinima ? sobra : margemMinima;
  }
}
