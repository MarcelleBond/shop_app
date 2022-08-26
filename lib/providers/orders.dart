import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/order_item_model.dart';



class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> products, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now.toString(),
        amount: total,
        products: products,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
