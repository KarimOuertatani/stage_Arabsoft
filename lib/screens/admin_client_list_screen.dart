import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/models/utilisateur.dart' as user;
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';

class AdminClientListScreen extends StatefulWidget {
  final int adminId;

  const AdminClientListScreen({super.key, required this.adminId});

  @override
  State<AdminClientListScreen> createState() => _AdminClientListScreenState();
}

class _AdminClientListScreenState extends State<AdminClientListScreen> {
  late Future<List<user.Utilisateur>> _clientsFuture;
  int _selectedIndex = 3;
  static const Color primaryColor = Colors.blueGrey;
  static const Color accentColor = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ApiService().fetchUtilisateursByType('CLIENT');
  }

  Future<void> _deleteClient(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce client ?'),
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
          _clientsFuture = ApiService().fetchUtilisateursByType('CLIENT');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client supprimé avec succès')),
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
        title: const Text('Liste des Clients'),
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
          future: _clientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun client disponible'));
            }

            final clients = snapshot.data!;
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${client.nom} ${client.prenom}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Email : ${client.email}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClient(client.id),
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