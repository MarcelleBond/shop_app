import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/Orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart' as od;
import '../models/order_item_model.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  
  
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => od.OrderItem(orderData.orders[index]),
        itemCount: orderData.orders.length,
      ),
      drawer: AppDrawer(),
    );
  }
}
