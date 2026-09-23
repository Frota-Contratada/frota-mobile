class CorridaFormatUtil {
  static String formatarValor(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    return 'R\$${partes[0]},${partes[1]}';
  }
}
