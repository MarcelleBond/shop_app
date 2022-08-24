import 'package:flutter/foundation.dart';

class CartItem {
  String id;
  String title;
  int quantaty;
  double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantaty,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }
  
  List<CartItem> get itemList{
    return [..._items.values];
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantaty;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          quantaty: value.quantaty + 1,
          price: value.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantaty: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }
  
  void removeItem(String productid){
    _items.remove(productid);
    notifyListeners();
  }
  
  void clear(){
    _items = {};
    notifyListeners();
  }
}
