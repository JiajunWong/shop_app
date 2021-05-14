import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String? id;
  final double? amount;
  final List<CartItem> products;
  final DateTime dateTime;

  const OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<OrderItem> _orders = [];

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
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
      final List<OrderItem> orders = [];
      data.forEach((key, value) {
        orders.add(OrderItem(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price']),
                )
                .toList(),
            dateTime: DateTime.parse(value['dateTime'])));
      });
      _orders = orders;
      notifyListeners();
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
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
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timestamp));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
