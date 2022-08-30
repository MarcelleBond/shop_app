import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products/$id.json");
    var oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      var response = await http.patch(
        url,
        body: json.encode(
          {
            "isFavorite": isFavorite,
          },
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (errro) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
