import 'package:flutter/material.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/apis/response_data.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/library/models/exceptions/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;

  final ShopApis _shopApis;
  List<ProductModel> _items = [];

  ProductsProvider(this.authToken, this.userId, this._items)
      : this._shopApis = ShopApis();

  @visibleForTesting
  ProductsProvider.testing(
      this.authToken, this.userId, this._items, this._shopApis);

  List<ProductModel> get items {
    return [..._items];
  }

  List<ProductModel> get favorites {
    return [..._items.where((element) => element.isFavorite).toList()];
  }

  ProductModel? findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchProducts() async {
    if (authToken == null || userId == null) {
      return;
    }

    try {
      final response = await _shopApis.getProductList(authToken!);
      final data = ResponseData(response).data;

      final List<ProductModel> products = [];
      ProductModel productModel;
      data.forEach((key, value) {
        productModel = ProductModel.fromJson(value);
        productModel.key = key;
        products.add(productModel);
      });

      final favoriteResponse =
          await _shopApis.getFavoriteProductList(authToken!, userId!);
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

  Future<void> addProduct(ProductModel product) async {
    if (_items.indexWhere((element) => element.id == product.id) >= 0 &&
        product.key != null) {
      return updateProduct(product.key!, product);
    }

    try {
      final response = await _shopApis.createProduct(authToken!, product);
      final data = ResponseData(response).data;
      product.key = data['name'];
      if (product.key != null) {
        _items.add(product);
        notifyListeners();
      } else {
        throw HttpException('Failed to create a new product');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String key, ProductModel product) async {
    try {
      await _shopApis.updateProduct(authToken!, key, product);
      final index = _items.indexWhere((element) => element.id == product.id);
      _items[index] = product;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String key, String id) async {
    try {
      final existingProductIndex =
          _items.indexWhere((element) => element.id == id);
      if (existingProductIndex < 0) {
        return;
      }

      var existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);
      final response =
          await _shopApis.deleteProduct(authToken!, key);

      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete the product');
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void toggleFavoriteStatus(
      String authToken, String userId, String productId) async {
    final product = findById(productId);
    if (product != null) {
      final oldState = product.isFavorite;
      product.isFavorite = !product.isFavorite;

      try {
        final response = await _shopApis.updateUserProductFavorite(
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
