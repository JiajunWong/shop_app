import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/app/custom_route.dart';
import 'package:shop_app/library/providers/auth_provider.dart';
import 'package:shop_app/library/providers/cart_provider.dart';
import 'package:shop_app/library/providers/orders_provider.dart';
import 'package:shop_app/library/providers/products_provider.dart';
import 'package:shop_app/features/authentication/auth_screen.dart';
import 'package:shop_app/features/cart/cart_screen.dart';
import 'package:shop_app/features/product_manage/edit_product_screen.dart';
import 'package:shop_app/features/order_list/orders_screen.dart';
import 'package:shop_app/features/product_detail/product_detail_screen.dart';
import 'package:shop_app/features/product_list/products_overview_screen.dart';
import 'package:shop_app/features/splash/splash_screen.dart';
import 'package:shop_app/features/product_manage/user_product_screen.dart';

class ShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
            create: (ctx) => ProductsProvider(null, null, []),
            update: (ctx, authProvider, previousProducts) => ProductsProvider(
                authProvider.token,
                authProvider.userId,
                previousProducts == null ? [] : previousProducts.items)),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
            create: (ctx) => OrderProvider(null, null, []),
            update: (ctx, auth, previousOrders) => OrderProvider(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        home: Consumer<AuthProvider>(
            builder: (ctx, authData, _) => authData.isAuth
                ? ProductsOverViewScreen()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen())),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductScreen.routeName: (ctx) => UserProductScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
        },
      ),
    );
  }
}
