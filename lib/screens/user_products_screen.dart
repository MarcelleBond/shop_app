import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";
  
  Future<void> _fetchProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }
  
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Your Products"), actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(EditProductScreen.routeName),
          icon: const Icon(Icons.add),
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemBuilder: (context, index) => Column(
              children: [
                UserProductItem(
                  title: productData.items[index].title,
                  imageUrl: productData.items[index].imageUrl,
                  id: productData.items[index].id,
                ),
                const Divider(),
              ],
            ),
            itemCount: productData.items.length,
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
