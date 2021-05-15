import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/providers/orders_provider.dart' show OrderProvider;
import 'package:shop_app/library/widgets/app_drawer.dart';
import 'package:shop_app/features/order_list/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _ordersFuture;

  Future _getOrdersFuture() {
    return Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _ordersFuture = _getOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (dataSnapshot.error == null) {
            return Consumer<OrderProvider>(builder: (ctx, ordersData, _) => ListView.builder(
              itemBuilder: (ctx, index) => OrderItem(ordersData.orders[index]),
              itemCount: ordersData.orders.length,
            ));
          } else {
            //do error
            return Text('error');
          }
        },
      ),
    );
  }
}
