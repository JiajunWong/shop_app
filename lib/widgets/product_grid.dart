import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/library/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool _showOnlyFavorite;

  const ProductGrid(this._showOnlyFavorite);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context);
    final products =
        _showOnlyFavorite ? productData.favorites : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) => ProductItem(products[index]),
      itemCount: products.length,
    );
  }
}
