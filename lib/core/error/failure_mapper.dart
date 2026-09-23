import 'exceptions.dart';
import 'failures.dart';

Failure mapServerException(ServerException exception) {
  return exception.isNetworkError
      ? NetworkFailure(exception.message)
      : ServerFailure(exception.message);
}
