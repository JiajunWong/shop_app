import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/models/auth_model.dart';
import 'package:shop_app/library/models/exceptions/http_exception.dart';

class AuthProvider with ChangeNotifier {
  AuthModel? _authModel;
  Timer? _authTimer;

  Future<SharedPreferences> _sharedPreferences;
  ShopApis _shopApis;

  AuthProvider(): this.testing(SharedPreferences.getInstance(), ShopApis());

  @visibleForTesting
  AuthProvider.testing(this._sharedPreferences, this._shopApis);

  bool get isAuth {
    return token != null;
  }

  AuthModel? get authModel {
    return authModel;
  }

  String? get userId {
    return _authModel?.userId;
  }

  String? get token {
    if (_authModel != null && _authModel!.expireDate.isAfter(DateTime.now())) {
      return _authModel?.token;
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await _sharedPreferences;
    if (!prefs.containsKey('auth')) {
      return false;
    } else {
      final data = json.decode(prefs.getString('auth')!);
      _authModel = AuthModel.fromJson(data);
      if (_authModel!.expireDate.isBefore(DateTime.now())) {
        return false;
      }
      notifyListeners();
      _autoLogout();
      return true;
    }
  }

  void logout() async {
    _authModel = null;
    _authTimer?.cancel();
    notifyListeners();
    final prefs = await _sharedPreferences;
    prefs.clear();
  }

  Future<void> auth(String email, String password, bool isLogin) async {
    try {
      final response = isLogin
          ? await _shopApis.login(email, password)
          : await _shopApis.signup(email, password);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _authModel = AuthModel.fromJson(responseData);
        _autoLogout();
        notifyListeners();
        final prefs = await _sharedPreferences;
        final userData = json.encode(_authModel!.toJson());
        prefs.setString('auth', userData);
      }
    } catch (error) {
      throw error;
    }
  }

  void _autoLogout() {
    if (_authModel?.expireDate != null) {
      _authTimer?.cancel();
      final timeToExpired =
          _authModel!.expireDate.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpired), () {
        logout();
      });
    }
  }
}
