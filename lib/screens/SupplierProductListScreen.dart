import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_add_screen.dart';
import 'product_edit_screen.dart';
import 'login_screen.dart';

class SupplierProductListScreen extends StatefulWidget {
  final int fournisseurId;

  const SupplierProductListScreen({super.key, required this.fournisseurId});

  @override
  State<SupplierProductListScreen> createState() => _SupplierProductListScreenState();
}

class _SupplierProductListScreenState extends State<SupplierProductListScreen> {
  late Future<List<Produit>> _produitsFuture;
  late Future<List<Categorie>> _categoriesFuture;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final Color primaryColor = Colors.blueGrey;
  final Color accentColor = Colors.blueGrey.shade700;

  @override
  void initState() {
    super.initState();
    _produitsFuture = ApiService().fetchProduits();
    _categoriesFuture = ApiService().fetchCategories();
  }

  List<Produit> _filterProduits(List<Produit> produits) {
    return produits.where((produit) {
      final matchesCategory = _selectedCategory == null || produit.categorie.nom == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty || produit.nom.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesFournisseur = produit.fournisseur.id == widget.fournisseurId;
      return matchesCategory && matchesSearch && matchesFournisseur;
    }).toList();
  }

  Future<void> _deleteProduit(int id) async {
    try {
      await ApiService().deleteProduit(id);
      setState(() {
        _produitsFuture = ApiService().fetchProduits();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit supprimé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Gestion des Produits'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductAddScreen()),
              ).then((_) {
                setState(() {
                  _produitsFuture = ApiService().fetchProduits();
                });
              });
            },
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Rechercher par nom de produit',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Categorie>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Aucune catégorie disponible');
                }
                final categories = ['Toutes', ...snapshot.data!.map((c) => c.nom)];
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(categories[index]),
                          selected: isSelected,
                          selectedColor: accentColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? accentColor : Colors.grey.shade300),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedCategory = categories[index] == 'Toutes' ? null : categories[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Produit>>(
                future: _produitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun produit trouvé', style: TextStyle(fontSize: 16)));
                  }
                  final filteredProduits = _filterProduits(snapshot.data!);
                  if (filteredProduits.isEmpty) {
                    return const Center(child: Text('Aucun produit correspondant', style: TextStyle(fontSize: 16)));
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 12,
                        headingRowColor: WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
                        dataRowHeight: 56,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Produit',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Catégorie',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Prix (€)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stock',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                        rows: filteredProduits.map((produit) {
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                produit.nom,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            DataCell(
                              Text(
                                produit.categorie.nom,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                produit.prix.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                produit.quantite.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: produit.quantite <= 10 ? Colors.red : Colors.black87,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ProductEditScreen(produit: produit)),
                                      ).then((_) {
                                        setState(() {
                                          _produitsFuture = ApiService().fetchProduits();
                                        });
                                      });
                                    },
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmer la suppression'),
                                          content: Text('Voulez-vous supprimer "${produit.nom}" ?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteProduit(produit.id);
                                              },
                                              child: const Text(
                                                'Supprimer',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
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
                    arguments: widget.fournisseurId);
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
                    arguments: widget.fournisseurId);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings',
                  arguments: widget.fournisseurId);
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
    );
  }
}