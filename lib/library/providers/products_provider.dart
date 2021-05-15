import 'package:flutter/material.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/models/auth_model.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  final ShopApis shopApis;

  ProductsProvider(this.authToken, this.userId, this._items)
      : this.shopApis = ShopApis();

  @visibleForTesting
  ProductsProvider.testing(
      this.authToken, this.userId, this._items, this.shopApis);

  List<ProductModel> _items = [
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

  Future<void> fetchProducts() async {
    if (authToken == null || userId == null) {
      return;
    }
    try {
      final response = await shopApis.getProductList(authToken!);
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) return;

      final favoriteResponse = await shopApis.getFavoriteProductList(
          authToken!, userId!);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<ProductModel> products = [];
      data.forEach((key, value) {
        products.add(ProductModel(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavorite: favoriteData == null ? false : favoriteData[key] ?? false,
        ));
      });
      _items = products;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<ProductModel> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<ProductModel> get favorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    if (_items.indexWhere((element) => element.id == product.id) >= 0) {
      return updateProduct(product.id, product);
    }

    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products.json?auth=${authToken!}';
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final newProduct = ProductModel(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, ProductModel product) async {
    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$id.json?auth=${authToken!}';
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

  ProductModel findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> deleteProduct(String id) {
    try {
      final existingProductIndex =
          _items.indexWhere((element) => element.id == id);
      var existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);

      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$id.json?auth=${authToken!}';
      return http.delete(Uri.parse(url)).then((response) {
        if (response.statusCode >= 400) {
          throw HttpException('Could not delete the product');
        }
        notifyListeners();
      }).catchError((ex) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw (ex);
      });
    } catch (error) {
      throw error;
    }
  }

// void toggleFavoriteStatus(String? authToken, String? userId) async {
//   final oldState = isFavorite;
//   isFavorite = !isFavorite;
//   notifyListeners();
//
//   try {
//     final String url =
//         'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
//     final response = await http.put(Uri.parse(url),
//         body: json.encode(isFavorite));
//     if (response.statusCode >= 400) {
//       throw HttpException("Toggle favorite failed");
//     }
//   } catch (error) {
//     isFavorite = oldState;
//     notifyListeners();
//     throw error;
//   }
// }
}
