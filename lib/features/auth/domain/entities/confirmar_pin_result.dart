import 'package:equatable/equatable.dart';
import '../enums/tipo_token.dart';

class ConfirmarPinResult extends Equatable {
  final String token;
  final TipoToken tipoToken;
  final DateTime expirationDate;

  const ConfirmarPinResult({
    required this.token,
    required this.tipoToken,
    required this.expirationDate,
  });

  @override
  List<Object?> get props => [token, tipoToken, expirationDate];
}
