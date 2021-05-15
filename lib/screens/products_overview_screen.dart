import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/models/exceptions/token_expire_exception.dart';
import 'package:shop_app/library/widgets/token_expire_alert.dart';
import 'package:shop_app/library/providers/cart_provider.dart';
import 'package:shop_app/library/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/product_grid.dart';

enum FliterOptions {
  Favorites,
  All,
}

class ProductsOverViewScreen extends StatefulWidget {
  @override
  _ProductsOverViewScreenState createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  var _showOnlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FliterOptions.Favorites),
              PopupMenuItem(child: Text('Show All'), value: FliterOptions.All),
            ],
            onSelected: (FliterOptions selectedValue) {
              switch (selectedValue) {
                case FliterOptions.Favorites:
                  setState(() {
                    _showOnlyFavorite = true;
                  });
                  break;
                case FliterOptions.All:
                default:
                  setState(() {
                    _showOnlyFavorite = false;
                  });
                  break;
              }
            },
            icon: Icon(Icons.more_vert),
          ),
          Consumer<CartProvider>(
            builder: (_, cartData, child) =>
                Badge(child: child, value: cartData.itemCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Provider.of<ProductsProvider>(context, listen: false)
              .fetchProducts(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (dataSnapshot.hasError) {
              if (dataSnapshot.error is TokenExpireException) {
                return TokenExpireAlert();
              } else {
                return Center(
                  child: Text(dataSnapshot.error.toString()),
                );
              }
            }
            return ProductGrid(_showOnlyFavorite);
          }),
    );
  }
}
