import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import '../models/cart_item_model.dart';
import '../models/order_item_model.dart';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? _authToken;
  String? _userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  set authToken(String? token) {
    _authToken = token;
  }
  
  set userId(String? userId){
    _userId = userId;
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");
    try {
      var response = await http.get(url);
      if (jsonDecode(response.body) == null) {
        return;
      }
      var data = json.decode(response.body) as Map<String, dynamic>;

      List<OrderItem> loadedOrders = [];
      data.forEach((orderId, order) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: order["amount"],
          dateTime: DateTime.parse(order["dateTime"]),
          products: (order["products"] as List<dynamic>)
              .map((e) => CartItem(
                  id: e["id"],
                  title: e["title"],
                  quantaty: e["quantaty"],
                  price: e["price"]))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");
    var timeStamp = DateTime.now();
    try {
      var response = await http.post(
        url,
        body: json.encode(
          {
            "amount": total,
            "dateTime": timeStamp.toIso8601String(),
            "products": products
                .map((e) => {
                      "id": e.id,
                      "title": e.title,
                      "quantaty": e.quantaty,
                      "price": e.price,
                    })
                .toList(),
          },
        ),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          products: products,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw HttpException("Failed to place order");
    }
  }
}
