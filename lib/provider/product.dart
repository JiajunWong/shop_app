import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String? authToken, String? userId) async {
    final oldState = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    try {
      final String url =
          'https://flutter-shop-app-9ce5e-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
       final response = await http.put(Uri.parse(url),
          body: json.encode(isFavorite));
       if (response.statusCode >= 400) {
         throw HttpException("Toggle favorite failed");
       }
    } catch (error) {
      isFavorite = oldState;
      notifyListeners();
      throw error;
    }
  }
}
