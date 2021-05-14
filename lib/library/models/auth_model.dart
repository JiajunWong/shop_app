import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel {
  @JsonKey(name: 'idToken')
  String token;
  @JsonKey(name: 'expiresIn')
  String expiresIn;
  @JsonKey(name: 'localId')
  String userId;
  @JsonKey(ignore: true)
  DateTime expireDate;

  AuthModel(this.token, this.expiresIn, this.userId)
      : expireDate = DateTime.now().add(Duration(seconds: int.parse(expiresIn)));

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}
