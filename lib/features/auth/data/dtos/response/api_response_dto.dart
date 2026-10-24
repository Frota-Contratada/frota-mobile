class ApiResponseDto<T> {
  final T response;

  const ApiResponseDto({required this.response});

  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final response = json['response'];
    if (response is! Map) {
      throw const FormatException('Resposta inválida do servidor.');
    }

    try {
      return ApiResponseDto(
        response: fromJsonT(Map<String, dynamic>.from(response)),
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Resposta inválida do servidor.');
    }
  }
}
