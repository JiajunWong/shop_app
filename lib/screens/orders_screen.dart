import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _getOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _ordersFuture = _getOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
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
          } else if (dataSnapshot.error == null) {
            return Consumer<Orders>(builder: (ctx, ordersData, _) => ListView.builder(
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
