import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    String? productId = ModalRoute.of(context)!.settings.arguments as String?;
    if (productId == null) {
      Navigator.of(context).pop();
    }
    // listen: false will prevent the UI rebuild when provider data change
    final product =
        Provider.of<ProductsProvider>(context, listen: false).findById(productId!);
    if (product == null) {
      Navigator.of(context).pop();
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(product.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product!.title),
              background: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${product.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 800,
            ),
          ])),
        ],
      ),
    );
  }
}
