class TokenExpireException implements Exception {
  final String message;

  const TokenExpireException(this.message);

  @override
  String toString() {
    return message;
  }
}
