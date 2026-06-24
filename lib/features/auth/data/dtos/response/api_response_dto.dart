class ApiResponseDto<T> {
  final T response;

  const ApiResponseDto({required this.response});

  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseDto(
      response: fromJsonT(json['response'] as Map<String, dynamic>),
    );
  }
}
