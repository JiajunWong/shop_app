import 'dart:convert';

import 'package:http/http.dart' as http;

class ShopApis {
  static const _API_KEY = '';
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
}
