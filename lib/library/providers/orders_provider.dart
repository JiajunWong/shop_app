import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/library/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/library/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<OrderModel> _orders = [];

  OrderProvider(this.authToken, this.userId, this._orders);

  List<OrderModel> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
      final response = await http.get(
        Uri.parse(url),
      );
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) return;
      final List<OrderModel> orders = [];
      data.forEach((key, value) {
        orders.add(OrderModel(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map(
                  (item) => CartModel(
                      id: item['id'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price']),
                )
                .toList(),
            dateTime: value['dateTime']));
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
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'dateTime': timestamp.toIso8601String(),
          }));
      _orders.insert(
          0,
          OrderModel(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timestamp.toIso8601String()));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
