import 'package:flutter/material.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/apis/response_data.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/library/models/exceptions/http_exception.dart';
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

  List<ProductModel> _items = [];

  Future<void> fetchProducts() async {
    if (authToken == null || userId == null) {
      return;
    }

    try {
      final response = await shopApis.getProductList(authToken!);
      final data = ResponseData(response).data;

      final List<ProductModel> products = [];
      ProductModel productModel;
      data.forEach((key, value) {
        productModel = ProductModel.fromJson(value);
        productModel.key = key;
        products.add(productModel);
      });

      final favoriteResponse =
          await shopApis.getFavoriteProductList(authToken!, userId!);
      var favoriteData = ResponseData(favoriteResponse).data;

      favoriteData.forEach((key, value) {
        products.firstWhere((element) => element.id == key).isFavorite = value;
      });

      _items = products;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<ProductModel> get items {
    return [..._items];
  }

  List<ProductModel> get favorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    if (_items.indexWhere((element) => element.id == product.id) >= 0 && product.key != null) {
      return updateProduct(product.key!, product);
    }

    try {
      final response = await shopApis.createProduct(authToken!, product);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['error'] != null) {
        throw HttpException(data['error'] as String);
      } else {
        product.key = json.decode(response.body)['name'];
        if (product.key != null) {
          _items.add(product);
          notifyListeners();
        }
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String key, ProductModel product) async {
    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$key.json?auth=${authToken!}';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final index = _items.indexWhere((element) => element.id == product.id);
      _items[index] = product;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  ProductModel? findById(String id) {
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

  void toggleFavoriteStatus(String authToken, String userId, String productId) async {
    final product = findById(productId);
    if (product != null) {
      final oldState = product.isFavorite;
      product.isFavorite = !product.isFavorite;

      try {
        final response = await shopApis.updateUserProductFavorite(
            authToken, userId, productId, product.isFavorite);
        if (response.statusCode >= 400) {
          throw HttpException("Toggle favorite failed");
        }
        notifyListeners();
      } catch (error) {
        product.isFavorite = oldState;
        notifyListeners();
        throw error;
      }
    }
  }
}
