import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const destinoPinImageName = 'frota-destino-pin';

const _corPin = Color(0xFF1E224F);
const _corContorno = Colors.white;
const _alturaLogica = 40.0;
const _espessuraContorno = 2.5;
const _margemSombra = 3.0;

const _iconeTopo = 2.0;
const _iconePonta = 22.0;
const _iconeEsquerda = 5.0;
const _iconeDireita = 19.0;

Future<Uint8List?> gerarDestinoPinImage(double pixelRatio) async {
  final escala = _alturaLogica / (_iconePonta - _iconeTopo);
  final folga = _espessuraContorno / 2 + _margemSombra;
  final largura = (_iconeDireita - _iconeEsquerda) * escala + folga * 2;
  final altura = _alturaLogica + folga + _espessuraContorno / 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(pixelRatio)
    ..translate(folga, folga)
    ..scale(escala)
    ..translate(-_iconeEsquerda, -_iconeTopo);

  final pin = _contornoDoPin();

  canvas.drawShadow(pin, Colors.black.withValues(alpha: 0.4), 2, false);
  canvas.drawPath(
    pin,
    Paint()
      ..color = _corContorno
      ..style = PaintingStyle.stroke
      ..strokeWidth = _espessuraContorno / escala
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawPath(pin, Paint()..color = _corPin);
  canvas.drawCircle(const Offset(12, 9), 2.6, Paint()..color = _corContorno);

  final imagem = await recorder.endRecording().toImage(
    (largura * pixelRatio).ceil(),
    (altura * pixelRatio).ceil(),
  );
  final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
  imagem.dispose();

  return bytes?.buffer.asUint8List();
}

Path _contornoDoPin() {
  return Path()
    ..moveTo(12, _iconeTopo)
    ..cubicTo(8.13, 2, _iconeEsquerda, 5.13, _iconeEsquerda, 9)
    ..cubicTo(_iconeEsquerda, 14.25, 12, _iconePonta, 12, _iconePonta)
    ..cubicTo(12, _iconePonta, _iconeDireita, 14.25, _iconeDireita, 9)
    ..cubicTo(_iconeDireita, 5.13, 15.87, 2, 12, _iconeTopo)
    ..close();
}
