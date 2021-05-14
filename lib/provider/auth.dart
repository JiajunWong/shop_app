import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('auth')) {
      return false;
    } else {
      final data = json.decode(prefs.getString('auth')) as Map<String, dynamic>;
      _expireDate = DateTime.parse(data['expireDate']);
      if (_expireDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = data['token'];
      _userId = data['userId'];
      notifyListeners();
      _autoLogout();
      return true;
    }
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) _authTimer.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpired = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpired), () {
      logout();
    });
  }

  Future<void> signup(String email, String password) async {
    try {
      final String url =
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=';
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expireDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expireDate': _expireDate.toIso8601String(),
        });
        prefs.setString('auth', userData);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final String url =
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=';
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expireDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expireDate': _expireDate.toIso8601String(),
        });
        prefs.setString('auth', userData);
      }
    } catch (error) {
      throw error;
    }
  }
}
