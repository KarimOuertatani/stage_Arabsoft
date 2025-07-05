import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_add_screen.dart';
import 'product_edit_screen.dart';
import 'login_screen.dart';
import 'dart:developer' as developer;

class SupplierMyProductListScreen extends StatefulWidget {
  final int fournisseurId;

  const SupplierMyProductListScreen({super.key, required this.fournisseurId});

  @override
  State<SupplierMyProductListScreen> createState() => _SupplierMyProductListScreenState();
}

class _SupplierMyProductListScreenState extends State<SupplierMyProductListScreen> {
  late Future<List<Produit>> _produitsFuture;
  late Future<List<Categorie>> _categoriesFuture;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final _storage = const FlutterSecureStorage();

  final Color mediumYellow = const Color(0xffF8B250);
  final Color darkGrey = const Color(0xff5E6172);

  @override
  void initState() {
    super.initState();
    _produitsFuture = ApiService().fetchProduits();
    _categoriesFuture = ApiService().fetchCategories();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<int> _getUserId() async {
    final clientId = await _storage.read(key: 'client_id');
    developer.log('client_id retrieved: ${clientId != null ? "Found: $clientId" : "Not found"}', name: 'getUserId');
    if (clientId == null) {
      throw Exception('ID utilisateur non trouvé dans le stockage sécurisé');
    }
    try {
      return int.parse(clientId);
    } catch (e) {
      throw Exception('Erreur lors de la conversion de l\'ID : $e');
    }
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: mediumYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un produit...',
            hintStyle: TextStyle(color: darkGrey.withOpacity(0.6)),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/icons/search_icon.svg',
                height: 20,
                color: darkGrey,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: darkGrey),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildCategoryChip(String label, int index) {
    final isSelected = index == _selectedCategoryIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : darkGrey,
          ),
        ),
        selected: isSelected,
        selectedColor: mediumYellow,
        backgroundColor: Colors.grey.shade200,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: (selected) {
          setState(() {
            _selectedCategoryIndex = index;
            _selectedCategory = label == 'Toutes' ? null : label;
          });
        },
      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
    );
  }

  Widget _buildImage(String? imageData, {double? height, double? width, BoxFit? fit}) {
    if (imageData == null) {
      return Center(
        child: Icon(
          Icons.image_not_supported,
          size: height != null ? height / 2 : 60,
          color: Colors.grey.shade400,
        ),
      ).animate().fadeIn(duration: 600.ms);
    }
    try {
      final decodedImage = base64Decode(imageData);
      return Image.memory(
        decodedImage,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.error,
            size: height != null ? height / 2 : 50,
            color: Colors.redAccent,
          ),
        ),
      ).animate().fadeIn(duration: 600.ms);
    } catch (e) {
      return Center(
        child: Icon(
          Icons.error,
          size: height != null ? height / 2 : 50,
          color: Colors.redAccent,
        ),
      ).animate().fadeIn(duration: 600.ms);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Image.asset(
                      'assets/icons/list.png',
                      height: 24,
                      color: darkGrey,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              Text(
                'Gestion des Produits',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/add_icon.svg',
              height: 24,
              color: darkGrey,
            ),
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
    ).animate().fadeIn(duration: 600.ms);

    Widget topHeader = Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
      child: FutureBuilder<List<Categorie>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox();
          }
          final categories = ['Toutes', ...snapshot.data!.map((c) => c.nom)];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categories.length, (index) {
                return _buildCategoryChip(categories[index], index);
              }),
            ),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  developer.log('Erreur de chargement de l\'image: $exception', name: 'BackgroundImage');
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: mediumYellow.withOpacity(0.5)),
          ),
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(child: appBar),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: topHeader),
                ];
              },
              body: FutureBuilder<List<Produit>>(
                future: _produitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun produit disponible'));
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
                        headingRowColor: WidgetStateProperty.all(mediumYellow.withOpacity(0.1)),
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
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: _buildImage(produit.image, height: 40, width: 40, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      produit.nom,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
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
                                  color: produit.quantite <= 10 ? Colors.red : darkGrey,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: darkGrey, size: 20),
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
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final List<Map<String, dynamic>> drawerItems = [
      {
        'icon': 'assets/icons/products_icon.svg',
        'label': 'Mes Produits',
        'onTap': () async {
          try {
            developer.log('Attempting to get userId', name: 'MesProduits');
            final userId = await _getUserId();
            developer.log('Navigation to /supplier-my-products with userId: $userId', name: 'MesProduits');
            Navigator.pushNamed(context, '/supplier-my-products', arguments: userId);
          } catch (e) {
            developer.log('Error in MesProduits: $e', name: 'MesProduits');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      },
      {
        'icon': 'assets/icons/orders_icon.svg',
        'label': 'Commandes',
        'onTap': () async {
          try {
            final userId = await _getUserId();
            Navigator.pushNamed(
              context,
              '/client-orders',
              arguments: userId,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      },
      {
        'icon': 'assets/icons/deliveries_icon.svg',
        'label': 'Livraisons',
        'onTap': () async {
          try {
            final userId = await _getUserId();
            Navigator.pushNamed(
              context,
              '/client-deliveries',
              arguments: userId,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      },
      {
        'icon': 'assets/icons/profile_icon.svg',
        'label': 'Profil',
        'onTap': () async {
          try {
            final userId = await _getUserId();
            Navigator.pushNamed(
              context,
              '/client-profile',
              arguments: userId,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      },
      {
        'icon': 'assets/icons/logout_icon.svg',
        'label': 'Déconnexion',
        'onTap': () async {
          try {
            final userId = await _getUserId();
            Navigator.pushNamed(
              context,
              '/client-logout',
              arguments: userId,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      },
    ];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              mediumYellow.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: mediumYellow,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Naviguez dans l\'application',
                    style: TextStyle(
                      color: darkGrey.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ...drawerItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: SvgPicture.asset(
                  item['icon'],
                  height: 24,
                  color: darkGrey,
                ),
                title: Text(
                  item['label'],
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  item['onTap']();
                },
                tileColor: Colors.transparent,
                hoverColor: mediumYellow.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ).animate().fadeIn(duration: 600.ms, delay: (200 * index).ms);
            }).toList(),
          ],
        ),
      ),
    ).animate().slideX(
          begin: -1.0,
          end: 0.0,
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}