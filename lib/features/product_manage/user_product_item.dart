import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/providers/products_provider.dart';
import 'package:shop_app/features/product_manage/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String? productKey;
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem({
    this.productKey,
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            if (productKey != null) IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<ProductsProvider>(context, listen: false).deleteProduct(productKey!, id);
                } catch (ex) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(ex.toString())));
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
