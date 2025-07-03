import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_detail_screen.dart';
import 'panier_screen.dart';
import 'profile_page.dart';
import 'orders_page.dart';
import 'deliveries_page.dart';
import 'logout_page.dart';
import '../app_properties.dart';

class ProductListScreen extends StatefulWidget {
  final int clientId;
  const ProductListScreen({super.key, required this.clientId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with TickerProviderStateMixin {
  late Future<List<Produit>> _produitsFuture;
  late Future<List<Categorie>> _categoriesFuture;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  late TabController tabController;
  final SwiperController _swiperController = SwiperController();
  RangeValues _priceRange = const RangeValues(0, 500);
  double _maxPrice = 500;

  final Color mediumYellow = const Color(0xffF8B250);
  final Color darkGrey = const Color(0xff5E6172);

  @override
  void initState() {
    super.initState();
    _produitsFuture = ApiService().fetchProduits();
    _categoriesFuture = ApiService().fetchCategories();
    tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    tabController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  List<Produit> _filterProduits(List<Produit> produits) {
    if (produits.isNotEmpty) {
      _maxPrice = produits.map((p) => p.prix).reduce((a, b) => a > b ? a : b);
    }
    return produits.where((produit) {
      final matchesCategory = _selectedCategory == null || produit.categorie.nom == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          produit.nom.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesPrice = produit.prix >= _priceRange.start && produit.prix <= _priceRange.end;
      return matchesCategory && matchesSearch && matchesPrice;
    }).toList();
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

  Widget _buildProductCarousel(List<Produit> produits) {
    double cardHeight = MediaQuery.of(context).size.height / 2.7;
    double cardWidth = MediaQuery.of(context).size.width / 1.8;

    return SizedBox(
      height: cardHeight,
      child: Swiper(
        itemCount: produits.length,
        itemBuilder: (_, index) {
          return _ProductCard(
            height: cardHeight,
            width: cardWidth,
            product: produits[index],
            onTap: () => _navigateToDetail(produits[index]),
          );
        },
        scale: 0.8,
        controller: _swiperController,
        viewportFraction: 0.6,
        loop: false,
        fade: 0.5,
        pagination: SwiperCustomPagination(
          builder: (context, config) {
            Color activeColor = mediumYellow;
            Color color = Colors.grey.withOpacity(.3);
            double size = 10.0;
            double space = 5.0;

            List<Widget> dots = [];
            for (int i = 0; i < config.itemCount; ++i) {
              bool active = i == config.activeIndex;
              dots.add(
                Container(
                  key: Key("pagination_$i"),
                  margin: EdgeInsets.all(space),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? activeColor : color,
                      ),
                      width: size,
                      height: size,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: dots,
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildRecommendedList(List<Produit> produits) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              IntrinsicHeight(
                child: Container(
                  margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                  width: 4,
                  color: mediumYellow,
                ),
              ),
              Center(
                child: Text(
                  'Recommandés',
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _navigateToDetail(produits[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: RadialGradient(
                      colors: [
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.7),
                      ],
                      center: const Alignment(0, 0),
                      radius: 0.6,
                      focal: const Alignment(0, 0),
                      focalRadius: 0.1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildImage(
                            produits[index].image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produits[index].nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${produits[index].prix.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
            },
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(Produit produit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(produit: produit)),
    ).then((_) {
      setState(() {
        _produitsFuture = ApiService().fetchProduits();
      });
    });
  }

  Widget _buildDrawer() {
    final List<Map<String, dynamic>> drawerItems = [
      {
        'icon': 'assets/icons/orders_icon.svg',
        'label': 'Commandes',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrdersPage(clientId: widget.clientId)),
            ),
      },
      {
        'icon': 'assets/icons/deliveries_icon.svg',
        'label': 'Livraisons',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DeliveriesPage(clientId: widget.clientId)),
            ),
      },
      {
        'icon': 'assets/icons/profile_icon.svg',
        'label': 'Profil',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage(clientId: widget.clientId)),
            ),
      },
      {
        'icon': 'assets/icons/logout_icon.svg',
        'label': 'Déconnexion',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LogoutPage(clientId: widget.clientId)),
            ),
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

  Widget _buildPriceFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plage de prix : ${_priceRange.start.toStringAsFixed(0)} € - ${_priceRange.end.toStringAsFixed(0)} €',
            style: TextStyle(
              color: darkGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: _maxPrice,
            divisions: 100,
            activeColor: mediumYellow,
            inactiveColor: Colors.grey.shade300,
            labels: RangeLabels(
              _priceRange.start.toStringAsFixed(0),
              _priceRange.end.toStringAsFixed(0),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 250.ms);
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
                'Liste des Produits',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/search_icon.svg',
                  height: 24,
                  color: darkGrey,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/cart_icon.svg',
                  height: 24,
                  color: darkGrey,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PanierScreen(clientId: widget.clientId)),
                ),
              ),
            ],
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

    Widget tabBar = Container(
      height: 40,
      child: TabBar(
        tabs: const [
          Tab(text: 'Tendance'),
          Tab(text: 'Sports'),
          Tab(text: 'Casques'),
          Tab(text: 'Sans fil'),
          Tab(text: 'Promotions'),
        ],
        labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 14.0),
        labelColor: mediumYellow,
        unselectedLabelColor: Colors.grey,
        isScrollable: true,
        indicatorColor: mediumYellow,
        indicatorWeight: 3,
        controller: tabController,
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);

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
                  print('Erreur de chargement de l\'image: $exception');
                },
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: transparentYellow),
          ),
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(child: appBar),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildPriceFilter()),
                  SliverToBoxAdapter(child: topHeader),
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<Produit>>(
                      future: _produitsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erreur : ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Aucun produit disponible'));
                        }
                        final produits = _filterProduits(snapshot.data!);
                        return _buildProductCarousel(produits);
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: tabBar),
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
                  final produits = _filterProduits(snapshot.data!);
                  return _buildRecommendedList(produits);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Produit product;
  final double height;
  final double width;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.height,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 30),
            height: height,
            width: width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              color: Color(0xffF8B250),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 12.0, 4.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          color: Color.fromRGBO(224, 69, 10, 1),
                        ),
                        child: Text(
                          '${product.prix.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: product.image ?? product.nom,
                child: Container(
                  height: height * 0.6,
                  width: width * 0.7,
                  child: _buildImage(context, product.image),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildImage(BuildContext context, String? imageData) {
    if (imageData == null) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      );
    }
    try {
      final decodedImage = base64Decode(imageData);
      return Image.memory(
        decodedImage,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          size: 60,
          color: Colors.redAccent,
        ),
      );
    } catch (e) {
      return const Icon(
        Icons.error,
        size: 60,
        color: Colors.redAccent,
      );
    }
  }
}