import 'dart:math';

import 'package:flutter/material.dart';
import '../provider/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _isExpanded ? min(widget.order.products.length * 20.0 + 110, 200) : 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                '\$${widget.order.amount}',
              ),
              subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: _isExpanded
                    ? Icon(Icons.expand_less)
                    : Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _isExpanded
                  ? min(widget.order.products.length * 20.0 + 10, 100)
                  : 0,
              child: ListView.builder(
                itemBuilder: (ctx, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.order.products[index].title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.order.products[index].quantity} X \$${widget.order.products[index].price}',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ),
                itemCount: widget.order.products.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
