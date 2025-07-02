import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final int adminId;

  const AdminHomeScreen({super.key, required this.adminId});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  late Future<Map<String, int>> _statsFuture;

  static const Color primaryColor = Color(0xFF344955);
  static const Color accentColor = Color(0xFFF9AA33);

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<Map<String, int>> _fetchStats() async {
    try {
      final produits = await ApiService().countProduits();
      final clients = await ApiService().countUtilisateursByType('CLIENT');
      final fournisseurs = await ApiService().countUtilisateursByType('FOURNISSEUR');
      return {
        'produits': produits,
        'clients': clients,
        'fournisseurs': fournisseurs,
      };
    } catch (e) {
      return {'produits': 0, 'clients': 0, 'fournisseurs': 0};
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

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Tableau de Bord Admin'),
        elevation: 3,
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
      body: SafeArea(
        child: FutureBuilder<Map<String, int>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }

            final stats = snapshot.data ?? {'produits': 0, 'clients': 0, 'fournisseurs': 0};

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Statistiques',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      _buildStatCard(
                        title: 'Produits',
                        count: stats['produits']!,
                        icon: Icons.inventory_2,
                        color: Colors.teal,
                      ),
                      _buildStatCard(
                        title: 'Clients',
                        count: stats['clients']!,
                        icon: Icons.people_outline,
                        color: Colors.blueAccent,
                      ),
                      _buildStatCard(
                        title: 'Fournisseurs',
                        count: stats['fournisseurs']!,
                        icon: Icons.local_shipping_outlined,
                        color: Colors.deepPurple,
                      ),
                    ]),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Bienvenue, Administrateur ! Vous pouvez gérer vos données depuis ce tableau de bord.',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNumber(count),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}