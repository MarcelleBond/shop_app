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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Text("An error occurred!");
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemBuilder: (context, index) =>
                      od.OrderItem(orderData.orders[index]),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
