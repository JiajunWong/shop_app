// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) {
  return AuthModel(
    json['idToken'] as String,
    json['expiresIn'] as String,
    json['localId'] as String,
  );
}

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
      'idToken': instance.token,
      'expiresIn': instance.expiresIn,
      'localId': instance.userId,
    };
