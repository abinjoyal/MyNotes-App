import 'app_exception.dart';

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code})
      : super(prefix: 'Database Error');
}
