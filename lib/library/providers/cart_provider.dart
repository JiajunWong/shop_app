import 'package:flutter/material.dart';
import 'package:shop_app/library/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartModel> _items = {};

  Map<String, CartModel> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (value) => CartModel(
              id: value.id,
              title: title,
              quantity: value.quantity + 1,
              price: price));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartModel(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (value) => CartModel(
              id: value.id,
              title: value.title,
              quantity: value.quantity - 1,
              price: value.price));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
