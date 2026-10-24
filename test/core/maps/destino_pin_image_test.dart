import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/maps/destino_pin_image.dart';

void main() {
  testWidgets('gera o pin de destino na densidade da tela', (tester) async {
    final bytes = await tester.runAsync(() => gerarDestinoPinImage(2));

    expect(bytes, isNotNull);

    final codec = await tester.runAsync(
      () => ui.instantiateImageCodec(bytes!),
    );
    final frame = await tester.runAsync(() => codec!.getNextFrame());
    final imagem = frame!.image;

    expect(imagem.width, 73);
    expect(imagem.height, 91);
    imagem.dispose();
  });
}
