import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop_app/library/models/exceptions/http_exception.dart';
import 'package:shop_app/library/models/exceptions/token_expire_exception.dart';

class ResponseData {
  static const _ERROR = 'error';
  static const _TOKEN_EXPIRED = 'Auth token is expired';
  final http.Response _response;

  const ResponseData(this._response);

  Map<String, dynamic> get data {
    final data = json.decode(_response.body) as Map<String, dynamic>;
    if (data[_ERROR] != null) {
      if (data[_ERROR] == _TOKEN_EXPIRED) {
        throw TokenExpireException(_TOKEN_EXPIRED);
      } else {
        throw HttpException(data[_ERROR]);
      }
    }
    return data;
  }
}
