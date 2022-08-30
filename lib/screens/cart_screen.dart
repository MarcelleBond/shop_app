import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/Orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      "R${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              ?.color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OderButton(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) => CartItem(
              id: cart.itemList[index].id,
              productId: cart.items.keys.toList()[index],
              title: cart.itemList[index].title,
              price: cart.itemList[index].price,
              quantaty: cart.itemList[index].quantaty,
            ),
            itemCount: cart.itemCount,
          ))
        ],
      ),
    );
  }
}

class OderButton extends StatefulWidget {
  const OderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OderButton> createState() => _OderButtonState();
}

class _OderButtonState extends State<OderButton> {
  @override
  Widget build(BuildContext context) {
    var _isLoading = false;
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.itemList,
          widget.cart.totalAmount,
        );
        setState(() {
          _isLoading = false;
        });
        widget.cart.clear();
      },
      style: TextButton.styleFrom(
        primary: Theme.of(context).colorScheme.primary,
      ),
      child: _isLoading ? Center(child: const CircularProgressIndicator()) : const Text("ORDER NOW"),
    );
  }
}
