import '../../models/usuario_model.dart';

class VerificacaoEmailResponseDto {
  final bool precisaCadastroSenha;
  final UsuarioModel? usuario;

  const VerificacaoEmailResponseDto({
    required this.precisaCadastroSenha,
    this.usuario,
  });

  factory VerificacaoEmailResponseDto.fromJson(Map<String, dynamic> json) {
    final primeiroAcesso = json['primeiroAcesso'] as bool?;
    final precisaCadastroSenha = json['precisaCadastroSenha'] as bool?;

    return VerificacaoEmailResponseDto(
      precisaCadastroSenha: primeiroAcesso ?? precisaCadastroSenha ?? false,
      usuario: json['usuario'] != null
          ? UsuarioModel.fromJson(json['usuario'] as Map<String, dynamic>)
          : null,
    );
  }
}
