// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return OrderModel(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    products: (json['products'] as List<dynamic>)
        .map((e) => CartModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    dateTime: json['dateTime'] as String,
  );
}

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'products': instance.products.map((e) => e.toJson()).toList(),
      'dateTime': instance.dateTime,
    };
