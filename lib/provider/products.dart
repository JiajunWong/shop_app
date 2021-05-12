import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/provider/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoriteOnly = false;
  //
  // void showFavorite() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchProducts() async {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) return;
      final List<Product> products = [];
      data.forEach((key, value) {
        products.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavorite: value['isFavorite'],
        ));
      });
      _items = products;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    if (_items.indexWhere((element) => element.id == product.id) >= 0) {
      return updateProduct(product.id, product);
    }

    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products.json';
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
    //     .then((response) {
    //   final newProduct = Product(
    //       title: product.title,
    //       description: product.description,
    //       price: product.price,
    //       imageUrl: product.imageUrl,
    //       id: json.decode(response.body)['name']);
    //   _items.add(newProduct);
    //   // _items.insert(0, newProduct);
    //   notifyListeners();
    // }).catchError((error){
    //   throw error;
    // });
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$id.json';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final index = _items.indexWhere((element) => element.id == id);
      _items[index] = product;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> deleteProduct(String id) {
    try {
      final existingProductIndex =
          _items.indexWhere((element) => element.id == id);
      var existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);

      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$id.json';
      return http.delete(Uri.parse(url)).then((response) {
        if (response.statusCode >= 400) {
          throw HttpException('Could not delete the product');
        }
        existingProduct = null;
        notifyListeners();
      }).catchError((ex) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw(ex);
      });
    } catch (error) {
      throw error;
    }
  }
}
