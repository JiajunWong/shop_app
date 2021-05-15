import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final ProductModel _productModel;

  const ProductItem(this._productModel);

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: _productModel.id,
            );
          },
          child: Hero(
            tag: _productModel.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(_productModel.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            _productModel.title,
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: Icon(_productModel.isFavorite
                ? Icons.favorite
                : Icons.favorite_border),
            // label: child
            color: Theme.of(context).accentColor,
            onPressed: () {
              // productData.toggleFavoriteStatus(authData.token, authData.userId);
            },
          ),
          // child: Text('never change'),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cartData.addItem(
                  _productModel.id, _productModel.price, _productModel.title);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Added item to cart'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    cartData.removeSingleItem(_productModel.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
