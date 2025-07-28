import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gestion_produit_flutter/screens/SupplierProductListScreen.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/screens/register_screen.dart';
import 'package:gestion_produit_flutter/screens/product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_my_product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_profile_screen.dart';
import 'package:gestion_produit_flutter/screens/settings_screen.dart';
import 'package:gestion_produit_flutter/screens/admin_home_screen.dart';
import 'package:gestion_produit_flutter/screens/admin_product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/admin_supplier_list_screen.dart';
import 'package:gestion_produit_flutter/screens/admin_client_list_screen.dart';
import 'package:gestion_produit_flutter/screens/admin_profile_screen.dart';
import 'package:gestion_produit_flutter/screens/panier_screen.dart';
import 'package:gestion_produit_flutter/screens/profile_page.dart';
import 'package:gestion_produit_flutter/screens/orders_page.dart';
import 'package:gestion_produit_flutter/screens/deliveries_page.dart';
import 'package:gestion_produit_flutter/screens/logout_page.dart';
import 'package:gestion_produit_flutter/screens/secret_code_screen.dart';
import 'package:gestion_produit_flutter/screens/ResetPasswordScreen.dart'; // Added import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Stripe directement avec la clé publique
  //Stripe.publishableKey = 'pk_test_51OHotbIUNFbNVA8jlkNNnNWUGVqaOyjbHcH0s17ZXUROh8NTz8Em3Jo664QWxIRPBjVoH5s88kUAt3QROCnzbxRR00zuiPCnup'; // Remplacez par votre clé publique Stripe
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/panier': (context) => const PanierScreen(),
        '/client-profile': (context) {
          final clientId = ModalRoute.of(context)!.settings.arguments as int;
          return ProfilePage(clientId: clientId);
        },
        '/client-orders': (context) {
          final clientId = ModalRoute.of(context)!.settings.arguments as int;
          return OrdersPage(clientId: clientId);
        },
        '/client-deliveries': (context) {
          final clientId = ModalRoute.of(context)!.settings.arguments as int;
          return DeliveriesPage(clientId: clientId);
        },
        '/client-logout': (context) {
          final clientId = ModalRoute.of(context)!.settings.arguments as int;
          return LogoutPage(clientId: clientId);
        },
        '/products': (context) => const SupplierProductListScreen(),
        '/profile': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SupplierProfileScreen(fournisseurId: fournisseurId);
        },
        '/settings': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SettingsScreen(fournisseurId: fournisseurId);
        },
        '/admin-home': (context) {
          final adminId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminHomeScreen(adminId: adminId);
        },
        '/admin-products': (context) {
          final adminId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminProductListScreen(adminId: adminId);
        },
        '/admin-suppliers': (context) {
          final adminId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminSupplierListScreen(adminId: adminId);
        },
        '/admin-clients': (context) {
          final adminId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminClientListScreen(adminId: adminId);
        },
        '/admin-profile': (context) {
          final adminId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminProfileScreen(adminId: adminId);
        },
        '/supplier-my-products': (context) {
          final fournisseurId = ModalRoute.of(context)!.settings.arguments as int;
          return SupplierMyProductListScreen(fournisseurId: fournisseurId);
        },
        '/secret-code': (context) {
          final clientId = ModalRoute.of(context)!.settings.arguments as int;
          return const SecretCodeScreen();
        },
        '/reset-password': (context) => const ResetPasswordScreen(), // Added route
      },
    );
  }
}