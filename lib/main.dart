import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/Orders.dart';
import './providers/auth.dart';
import 'helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (BuildContext context) => Products(),
            update: (BuildContext context, auth, Products? previous) {
              previous!.authToken = auth.token;
              previous.userId = auth.userId;
              return previous;
            }),
        ChangeNotifierProvider(create: (BuildContext context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (BuildContext context) => Orders(),
            update: (BuildContext context, auth, Orders? previous) {
              previous!.authToken = auth.token;
              previous.userId = auth.userId;
              return previous;
            }),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            fontFamily: "Lato",
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder()
                },)
          ),
          home: auth.isAuth
              ? const ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (context) =>
                const ProductDetailScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            OrdersScreen.routeName: (context) => const OrdersScreen(),
            UserProductsScreen.routeName: (context) =>
                const UserProductsScreen(),
            EditProductScreen.routeName: (context) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
