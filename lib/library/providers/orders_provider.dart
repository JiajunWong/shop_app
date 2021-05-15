import 'package:flutter/foundation.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/apis/response_data.dart';
import 'package:shop_app/library/models/cart_model.dart';
import 'package:shop_app/library/models/order_model.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;

  final ShopApis _shopApis;
  List<OrderModel> _orders = [];

  OrderProvider(this.authToken, this.userId, this._orders)
      : _shopApis = ShopApis();

  @visibleForTesting
  OrderProvider.test(this.authToken, this.userId, this._orders, this._shopApis);

  List<OrderModel> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    try {
      final response = await _shopApis.getOrderList(authToken!, userId!);
      final data = ResponseData(response).data;
      if (data == null) {
        return;
      }
      final List<OrderModel> orders = [];
      data.forEach((key, value) {
        orders.add(OrderModel.fromJson(value));
      });
      _orders = orders;
      notifyListeners();
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> addOrder(List<CartModel> cartProducts, double total) async {
    try {
      final timestamp = DateTime.now();
      final order = OrderModel(
          id: Uuid().v1(),
          amount: total,
          products: cartProducts,
          dateTime: timestamp.toIso8601String());
      await _shopApis.createOrder(authToken!, userId!, order);
      _orders.insert(0, order);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
