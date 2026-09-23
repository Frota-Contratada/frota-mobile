import 'package:equatable/equatable.dart';
import 'usuario.dart';

class VerificacaoEmailResult extends Equatable {
  final Usuario usuario;
  final bool precisaCadastroSenha;

  const VerificacaoEmailResult({
    required this.usuario,
    required this.precisaCadastroSenha,
  });

  @override
  List<Object?> get props => [usuario, precisaCadastroSenha];
}
