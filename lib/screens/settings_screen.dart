import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final int fournisseurId;

  const SettingsScreen({super.key, required this.fournisseurId});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blueGrey;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Paramètres'),
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Text(
                'Menu Fournisseur',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon Profil'),
              selected: ModalRoute.of(context)?.settings.name == '/profile',
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/profile') {
                  Navigator.pushReplacementNamed(context, '/profile',
                      arguments: fournisseurId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Mes Produits'),
              selected: ModalRoute.of(context)?.settings.name == '/products',
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/products') {
                  Navigator.pushReplacementNamed(context, '/products',
                      arguments: fournisseurId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se Déconnecter', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Page des paramètres (à implémenter)',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}