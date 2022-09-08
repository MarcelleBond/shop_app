import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? _authToken;
  String? _userId;

  List<Product> get items {
    return [..._items];
  }
  
  set authToken(String? token){
      _authToken = token;
  }
  
  set userId(String? userId){
    _userId = userId;
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var filter = filterByUser == true ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url = Uri.parse('https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products.json?auth=$_authToken&$filter');
    
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400){
        print(response.body);
        throw HttpException("Could not load products at the moment");
      }
      
      if (jsonDecode(response.body) == null) {
        return;
      }
      
      final extract = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse("https://flutter-shop-app-95618-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken");
      final favResponse = await http.get(url);
      final favExtract = json.decode(favResponse.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extract.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            imageUrl: prodData["imageUrl"],
            price: prodData["price"],
            isFavorite: favExtract == null ? false : favExtract[prodId] ?? false,
          ),
        );
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products.json?auth=$_authToken");

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "creatorId": _userId,
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
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
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken");
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
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://flutter-shop-app-95618-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken");
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
