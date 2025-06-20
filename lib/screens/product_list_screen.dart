import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_add_screen.dart';
import 'product_detail_screen.dart';
import '../constants.dart';

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

  @override
  void initState() {
    super.initState();
    _produitsFuture = ApiService().fetchProduits();
    _categoriesFuture = ApiService().fetchCategories();
  }

  List<Produit> _filterProduits(List<Produit> produits) {
    return produits.where((produit) {
      final matchesCategory = _selectedCategory == null || produit.categorie.nom == _selectedCategory;
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
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: kTextLightColor,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/back.svg",
            colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/cart.svg",
              colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: kTextColor),
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
          const SizedBox(width: kDefaultPaddin / 2),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin, vertical: kDefaultPaddin),
            child: Text(
              "Produits",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: kTextColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit',
                hintStyle: const TextStyle(color: kTextLightColor),
                prefixIcon: SvgPicture.asset(
                  "assets/icons/search.svg",
                  colorFilter: const ColorFilter.mode(kTextLightColor, BlendMode.srcIn),
                  height: 20,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          FutureBuilder<List<Categorie>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(kDefaultPaddin),
                  child: Center(child: CircularProgressIndicator(color: kTextColor)),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                  child: Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                  child: Text(
                    'Aucune catégorie disponible',
                    style: TextStyle(color: kTextLightColor),
                  ),
                );
              }
              final categories = ['Toutes', ...snapshot.data!.map((c) => c.nom)];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                            _selectedCategory = categories[index] == 'Toutes' ? null : categories[index];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categories[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedCategoryIndex == index ? kTextColor : kTextLightColor,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: kDefaultPaddin / 4),
                                height: 2,
                                width: 30,
                                color: _selectedCategoryIndex == index ? kTextColor : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Produit>>(
              future: _produitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kTextColor));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur : ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun produit trouvé',
                      style: TextStyle(color: kTextLightColor),
                    ),
                  );
                }
                final filteredProduits = _filterProduits(snapshot.data!);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin, vertical: kDefaultPaddin / 2),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: kDefaultPaddin,
                      crossAxisSpacing: kDefaultPaddin,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProduits.length,
                    itemBuilder: (context, index) {
                      final produit = filteredProduits[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(produit: produit),
                            ),
                          ).then((_) {
                            setState(() {
                              _produitsFuture = ApiService().fetchProduits();
                            });
                          });
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                padding: const EdgeInsets.all(kDefaultPaddin / 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produit.nom,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: kTextColor,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: kDefaultPaddin / 4),
                                    Text(
                                      '${produit.prix.toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: kTextColor,
                                      ),
                                    ),
                                    Text(
                                      'Qté : ${produit.quantite}',
                                      style: const TextStyle(color: kTextLightColor),
                                    ),
                                    Text(
                                      produit.categorie.nom,
                                      style: const TextStyle(color: kTextLightColor),
                                    ),
                                    Text(
                                      produit.fournisseur.nom,
                                      style: const TextStyle(color: kTextLightColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}