import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products.json");
    try {
      final response = await http.get(url);
      if (jsonDecode(response.body) == null) {
        return;
      }
      final extract = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extract.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            imageUrl: prodData["imageUrl"],
            price: prodData["price"],
            isFavorite: prodData["isFavorite"],
          ),
        );
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products.json");

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "isFavorite": product.isFavorite
          },
        ),
      );

      var newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products/$id.json");
    try {
      await http.patch(
        url,
        body: json.encode(
          {
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
          },
        ),
      );
      var prodIndex = _items.indexWhere((element) => element.id == id);
      _items[prodIndex] = product;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products/$id.json");
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    existingProduct = null;
  }
}
