class AuthModel {
  final String token;
  final DateTime expireDate;
  final String userId;

  const AuthModel(this.token, this.expireDate, this.userId);
}
