import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop_app/library/models/product_model.dart';

class ShopApis {
  static const _API_KEY = 'AIzaSyBJJU_uhGn09M-BRMbXjaYK32rWl-o_SDc';
  static final ShopApis _singleton = ShopApis._internal();

  factory ShopApis(){
    return _singleton;
  }

  ShopApis._internal();

  Future<http.Response> login(String email, String password) {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_API_KEY';
    return http.post(Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
  }

  Future<http.Response> signup(String email, String password) {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_API_KEY';
    return http.post(Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
  }

  Future<http.Response> getProductList(String authToken) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    return http.get(Uri.parse(url));
  }

  Future<http.Response> getFavoriteProductList(String authToken, String userId) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
    return http.get(Uri.parse(url));
  }

  Future<http.Response> updateUserProductFavorite(String authToken, String userId, String productId, bool isFavorite) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/userFavorites/$userId/$productId.json?auth=$authToken';
    return http.put(Uri.parse(url), body: json.encode(isFavorite));
  }

  Future<http.Response> createProduct(String authToken, ProductModel product) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products.json?auth=${authToken}';
    return http.post(Uri.parse(url), body: json.encode(product.toJson()));
  }

  Future<http.Response> updateProduct(String authToken, String key, ProductModel product) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$key.json?auth=$authToken';
    return http.patch(Uri.parse(url), body: json.encode(product.toJson()));
  }

  Future<http.Response> deleteProduct(String authToken, String key) {
    final String url =
        'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/products/$key.json?auth=$authToken';
    return http.delete(Uri.parse(url));
  }
}
