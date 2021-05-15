import 'package:json_annotation/json_annotation.dart';
import 'package:shop_app/library/models/cart_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel {
  final String id;
  final double amount;
  final List<CartModel> products;
  final String dateTime;

  const OrderModel({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
