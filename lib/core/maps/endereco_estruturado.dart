import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import 'map_point.dart';


class EnderecoEstruturado {
  final String logradouro;
  final String cidade;
  final String uf;
  final double latitude;
  final double longitude;
  final String? numero;
  final String? bairro;
  final String? cep;

  const EnderecoEstruturado({
    required this.logradouro,
    required this.cidade,
    required this.uf,
    required this.latitude,
    required this.longitude,
    this.numero,
    this.bairro,
    this.cep,
  });

  Map<String, dynamic> toJson() => {
    'logradouro': logradouro,
    'cidade': cidade,
    'uf': uf,
    'latitude': latitude,
    'longitude': longitude,
    if (numero != null) 'numero': numero,
    if (bairro != null) 'bairro': bairro,
    if (cep != null) 'cep': cep,
  };
}

class EnderecoNaoIdentificadoException implements Exception {
  final String message;

  const EnderecoNaoIdentificadoException([
    this.message =
        'Não foi possível identificar o endereço do ponto selecionado. '
            'Escolha o ponto novamente.',
  ]);

  @override
  String toString() => message;
}

Future<EnderecoEstruturado> resolverEnderecoEstruturado(
  MapPoint ponto, {
  String? descricaoFallback,
}) async {
  Placemark? place;

  try {
    final placemarks = await Geocoding().placemarkFromCoordinates(
      ponto.latitude,
      ponto.longitude,
    );

    place = placemarks.isEmpty ? null : placemarks.first;
  } catch (error, stackTrace) {
    debugPrint('Erro ao resolver endereço estruturado: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  final logradouro = _primeiroNaoVazio([
    place?.thoroughfare,
    place?.street,
    descricaoFallback,
  ]);

  final cidade = _primeiroNaoVazio([
    place?.locality,
    place?.subAdministrativeArea,
  ]);

  final uf = _paraUf(place?.administrativeArea);

  if (logradouro == null || cidade == null || uf == null) {
    throw const EnderecoNaoIdentificadoException();
  }

  return EnderecoEstruturado(
    logradouro: _limitar(logradouro, 200),
    cidade: _limitar(cidade, 100),
    uf: uf,
    latitude: ponto.latitude,
    longitude: ponto.longitude,
    numero: _opcional(place?.subThoroughfare, 20),
    bairro: _opcional(place?.subLocality, 100),
    cep: _opcional(place?.postalCode?.replaceAll(RegExp(r'\D'), ''), 10),
  );
}

String? _primeiroNaoVazio(List<String?> valores) {
  for (final valor in valores) {
    final texto = valor?.trim();
    if (texto != null && texto.isNotEmpty) return texto;
  }

  return null;
}

String? _opcional(String? valor, int limite) {
  final texto = valor?.trim();
  if (texto == null || texto.isEmpty) return null;
  return _limitar(texto, limite);
}

String _limitar(String valor, int limite) =>
    valor.length <= limite ? valor : valor.substring(0, limite);

String? _paraUf(String? administrativeArea) {
  final valor = administrativeArea?.trim();

  if (valor == null || valor.isEmpty) return null;
  if (valor.length == 2) return valor.toUpperCase();

  return _ufPorEstado[_semAcento(valor.toLowerCase())];
}

String _semAcento(String valor) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  var resultado = valor;

  for (var i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }

  return resultado;
}

const _ufPorEstado = <String, String>{
  'acre': 'AC',
  'alagoas': 'AL',
  'amapa': 'AP',
  'amazonas': 'AM',
  'bahia': 'BA',
  'ceara': 'CE',
  'distrito federal': 'DF',
  'espirito santo': 'ES',
  'goias': 'GO',
  'maranhao': 'MA',
  'mato grosso': 'MT',
  'mato grosso do sul': 'MS',
  'minas gerais': 'MG',
  'para': 'PA',
  'paraiba': 'PB',
  'parana': 'PR',
  'pernambuco': 'PE',
  'piaui': 'PI',
  'rio de janeiro': 'RJ',
  'rio grande do norte': 'RN',
  'rio grande do sul': 'RS',
  'rondonia': 'RO',
  'roraima': 'RR',
  'santa catarina': 'SC',
  'sao paulo': 'SP',
  'sergipe': 'SE',
  'tocantins': 'TO',
};
