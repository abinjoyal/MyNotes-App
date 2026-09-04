class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? code;

  const AppException(
    this.message, {
    this.prefix,
    this.code,
  });

  @override
  String toString() {
    final prefixStr = prefix != null ? '$prefix: ' : '';
    final codeStr = code != null ? ' [$code]' : '';
    return '$prefixStr$message$codeStr';
  }
}
