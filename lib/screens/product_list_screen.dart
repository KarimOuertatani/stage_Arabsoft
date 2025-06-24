import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_add_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Produit>> _produitsFuture;
  late Future<List<Categorie>> _categoriesFuture;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final Color primaryColor = Colors.deepPurple;
  final Color accentColor = Colors.deepPurpleAccent;

  @override
  void initState() {
    super.initState();
    _produitsFuture = ApiService().fetchProduits();
    _categoriesFuture = ApiService().fetchCategories();
  }

  List<Produit> _filterProduits(List<Produit> produits) {
    return produits.where((produit) {
      final matchesCategory =
          _selectedCategory == null || produit.categorie.nom == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          produit.nom.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildImage(String? imageData) {
    if (imageData == null) {
      return Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey.shade400,
        ),
      );
    }
    try {
      final decodedImage = base64Decode(imageData);
      return Image.memory(
        decodedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.error,
            size: 50,
            color: Colors.redAccent,
          ),
        ),
      );
    } catch (e) {
      return const Center(
        child: Icon(
          Icons.error,
          size: 50,
          color: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Liste des Produits'),
        actions: [
          // Bouton + (ajout produit)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher un produit',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Catégories
            FutureBuilder<List<Categorie>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
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
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(categories[index]),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedCategory =
                                  categories[index] == 'Toutes' ? null : categories[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Liste produits
            Expanded(
              child: FutureBuilder<List<Produit>>(
                future: _produitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erreur : ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun produit trouvé'));
                  }
                  final filteredProduits = _filterProduits(snapshot.data!);
                  if (filteredProduits.isEmpty) {
                    return const Center(child: Text('Aucun produit correspondant'));
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProduits.length,
                    itemBuilder: (context, index) {
                      final produit = filteredProduits[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(produit: produit),
                            ),
                          ).then((_) {
                            setState(() {
                              _produitsFuture = ApiService().fetchProduits();
                            });
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: primaryColor.withOpacity(0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: _buildImage(produit.image),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produit.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${produit.prix.toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qté: ${produit.quantite}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                    Text(
                                      produit.categorie.nom,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                    Text(
                                      produit.fournisseur.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
