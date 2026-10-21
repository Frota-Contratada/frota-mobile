import 'map_point.dart';

class EnderecoSugestao {
  final String descricao;
  final MapPoint ponto;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? cep;

  const EnderecoSugestao({
    required this.descricao,
    required this.ponto,
    this.logradouro,
    this.numero,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
  });

  String get titulo {
    final partes = [
      logradouro,
      numero,
    ].whereType<String>().where((parte) => parte.isNotEmpty);

    return partes.isEmpty ? descricao : partes.join(', ');
  }

  String get subtitulo {
    final partes = [
      bairro,
      cidade,
      uf,
    ].whereType<String>().where((parte) => parte.isNotEmpty);

    return partes.join(', ');
  }

  factory EnderecoSugestao.fromJson(Map<String, dynamic> json) {
    String? texto(String chave) {
      final valor = json[chave];
      if (valor is! String) return null;
      final limpo = valor.trim();
      return limpo.isEmpty ? null : limpo;
    }

    return EnderecoSugestao(
      descricao: texto('descricao') ?? '',
      ponto: MapPoint(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      logradouro: texto('logradouro'),
      numero: texto('numero'),
      bairro: texto('bairro'),
      cidade: texto('cidade'),
      uf: texto('uf'),
      cep: texto('cep'),
    );
  }
}
