import 'package:equatable/equatable.dart';
import '../../../../../core/maps/map_point.dart';

class EnderecoSolicitacao extends Equatable {
  final int id;
  final String descricao;
  final String logradouro;
  final String cidade;
  final String uf;
  final double latitude;
  final double longitude;
  final String? numero;
  final String? bairro;

  const EnderecoSolicitacao({
    required this.id,
    required this.descricao,
    required this.logradouro,
    required this.cidade,
    required this.uf,
    required this.latitude,
    required this.longitude,
    this.numero,
    this.bairro,
  });

  MapPoint get ponto => MapPoint(latitude, longitude);

  @override
  List<Object?> get props => [
    id,
    descricao,
    logradouro,
    cidade,
    uf,
    latitude,
    longitude,
    numero,
    bairro,
  ];
}
