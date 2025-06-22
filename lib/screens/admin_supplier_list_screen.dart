import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/models/utilisateur.dart' as user;
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';

class AdminSupplierListScreen extends StatefulWidget {
  final int adminId;

  const AdminSupplierListScreen({super.key, required this.adminId});

  @override
  State<AdminSupplierListScreen> createState() => _AdminSupplierListScreenState();
}

class _AdminSupplierListScreenState extends State<AdminSupplierListScreen> {
  late Future<List<user.Utilisateur>> _fournisseursFuture;
  int _selectedIndex = 2;
  static const Color primaryColor = Colors.blueGrey;
  static const Color accentColor = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _fournisseursFuture = ApiService().fetchUtilisateursByType('FOURNISSEUR');
  }

  Future<void> _deleteFournisseur(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce fournisseur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().deleteUtilisateur(id);
        setState(() {
          _fournisseursFuture = ApiService().fetchUtilisateursByType('FOURNISSEUR');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fournisseur supprimé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin-home', arguments: widget.adminId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin-products', arguments: widget.adminId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin-suppliers', arguments: widget.adminId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin-clients', arguments: widget.adminId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/admin-profile', arguments: widget.adminId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Liste des Fournisseurs'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<user.Utilisateur>>(
          future: _fournisseursFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun fournisseur disponible'));
            }

            final fournisseurs = snapshot.data!;
            return ListView.builder(
              itemCount: fournisseurs.length,
              itemBuilder: (context, index) {
                final fournisseur = fournisseurs[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${fournisseur.nom} ${fournisseur.prenom}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Email : ${fournisseur.email}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFournisseur(fournisseur.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Fournisseurs'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}