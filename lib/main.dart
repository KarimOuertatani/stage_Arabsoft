import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/screens/register_screen.dart';
import 'package:gestion_produit_flutter/screens/product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_profile_screen.dart' hide SupplierProfileScreen;
import 'package:gestion_produit_flutter/screens/settings_screen.dart';
import 'package:gestion_produit_flutter/screens/Supplier_Profile_Screen.dart' hide SupplierProfileScreen;
import 'screens/SupplierProductListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Produits',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/client-products': (context) => const ProductListScreen(),
        '/products': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SupplierProductListScreen(fournisseurId: fournisseurId);
        },
        '/profile': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SupplierProfileScreen(fournisseurId: fournisseurId);
        },
        '/settings': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SettingsScreen(fournisseurId: fournisseurId);
        },
      },
    );
  }
}