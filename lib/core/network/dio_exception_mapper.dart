import 'package:dio/dio.dart';
import '../error/exceptions.dart';

ServerException mapDioException(DioException exception) {
  final data = exception.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return ServerException(message);
    }
    if (message is List && message.isNotEmpty) {
      return ServerException(message.map((item) => item.toString()).join('\n'));
    }
  }
  return const ServerException();
}
