import '../../../domain/entities/preferencias_notificacao.dart';

class PreferenciasNotificacaoResponseDto {
  final bool pushAtivo;
  final Map<String, bool> categorias;

  const PreferenciasNotificacaoResponseDto({
    required this.pushAtivo,
    required this.categorias,
  });

  factory PreferenciasNotificacaoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final pushAtivo = json['pushAtivo'];
    final categorias = json['categorias'];
    if (pushAtivo is! bool || categorias is! Map) {
      throw const FormatException('Resposta de preferências inválida.');
    }

    return PreferenciasNotificacaoResponseDto(
      pushAtivo: pushAtivo,
      categorias: {
        for (final entrada in categorias.entries)
          if (entrada.key is String && entrada.value is bool)
            entrada.key as String: entrada.value as bool,
      },
    );
  }

  PreferenciasNotificacao toEntity() => PreferenciasNotificacao(
    pushAtivo: pushAtivo,
    categorias: {
      for (final categoria in CategoriaNotificacao.values)
        categoria: categorias[categoria.codigo] ?? true,
    },
  );
}
