import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantaty;

  const CartItem(
      {required this.id,
      required this.title,
      required this.price,
      required this.quantaty});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                child: Text("R$price"),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text("Total: R${(price * quantaty)}"),
          trailing: Text("$quantaty X"),
        ),
      ),
    );
  }
}
