import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authToken = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
              icon: Consumer<Product>(
                builder: (context, product, _) => Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
              onPressed: () => product.toggleFavoriteStatus(
                  authToken.token, authToken.userId),
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Item added to cart"),
                action: SnackBarAction(
                  label: "UNDO",
                  onPressed: () => cart.removeSingleItem(product.id),
                ),
              ));
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
                placeholder:
                    const AssetImage("assets/images/product-placeholder.png"),
                image: NetworkImage(
                  product.imageUrl,
                ),
                fit: BoxFit.cover,
              ),
          ),
          ),
        ),
    );
  }
}
