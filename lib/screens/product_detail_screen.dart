import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_produit_flutter/screens/panier_screen.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import '../constants.dart';
import 'product_edit_screen.dart';


class ProductDetailScreen extends StatefulWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Produit _produit;
  final int clientId = 1; // TODO: Remplacer par utilisateur connecté si nécessaire
  int activeColorIndex = 0; // For color selection
  final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.yellow,
  ]; // Sample colors from template

  @override
  void initState() {
    super.initState();
    _produit = widget.produit;
  }

  void _refreshProduit() async {
    try {
      final updatedProduit = await ApiService()
          .fetchProduits()
          .then((list) => list.firstWhere((p) => p.id == _produit.id));
      setState(() {
        _produit = updatedProduit;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du rafraîchissement : $e')),
      );
    }
  }

  void _acheterProduit() async {
    try {
      await ApiService().ajouterProduitAuPanier(
        clientId: clientId,
        produitId: _produit.id,
        quantite: 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté au panier')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout au panier : $e")),
      );
    }
  }

  Widget _buildImage() {
    if (_produit.image == null) {
      return const Icon(Icons.image_not_supported, size: 100, color: Colors.white);
    }

    try {
      final decodedImage = base64Decode(_produit.image!);
      return Image.memory(
        decodedImage,
        height: 230,
        width: 230,
        fit: BoxFit.contain,
      );
    } catch (e) {
      return const Icon(Icons.error, size: 100, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const Color yellow = Color(0xFFFBD085); // From template
    const Color darkGrey = Color(0xFF2F2F2F); // From template
    const List<Shadow> shadow = [
      Shadow(
        color: Color.fromRGBO(0, 0, 0, 0.16),
        offset: Offset(0, 3),
        blurRadius: 6.0,
      ),
    ];
    const LinearGradient mainButton = LinearGradient(
      colors: [
        Color.fromRGBO(236, 60, 3, 1),
        Color.fromRGBO(234, 60, 3, 1),
        Color.fromRGBO(216, 78, 16, 1),
      ],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
    );

    Widget acheterButton = InkWell(
      onTap: _acheterProduit,
      child: Container(
        width: size.width / 2.5,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Acheter",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );

    Widget panierButton = InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PanierScreen(clientId: clientId)),
        );
      },
      child: Container(
        width: size.width / 2.5,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Voir Panier",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );

    Widget productDisplay = Stack(
      children: [
        Positioned(
          top: 30.0,
          right: 0,
          child: Container(
            width: size.width / 1.5,
            height: 85,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: darkGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  offset: Offset(0, 3),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Align(
              alignment: const Alignment(1, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_produit.prix.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Montserrat",
                        fontSize: 36.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-1, 0),
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: _buildImage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    Widget colorListWidget = SizedBox(
      height: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Couleur',
              style: TextStyle(color: Colors.white, shadows: shadow),
            ),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colorList.length,
              itemBuilder: (_, index) => InkWell(
                onTap: () {
                  setState(() {
                    activeColorIndex = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: Transform.scale(
                    scale: activeColorIndex == index ? 1.2 : 1,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        color: colorList[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget moreProducts = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0, bottom: 8.0),
          child: Text(
            'Autres produits',
            style: TextStyle(color: Colors.white, shadows: shadow),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          height: 250,
          child: FutureBuilder<List<Produit>>(
            future: ApiService().fetchProduits(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erreur de chargement'));
              }
              final products = snapshot.data?.where((p) => p.id != _produit.id).toList() ?? [];
              return ListView.builder(
                itemCount: products.length > 3 ? 3 : products.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: index == 0
                        ? const EdgeInsets.only(left: 24.0, right: 8.0)
                        : index == 2
                            ? const EdgeInsets.only(right: 24.0, left: 8.0)
                            : const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(produit: products[index]),
                          ),
                        );
                      },
                      child: Container(
                        height: 250,
                        width: size.width / 2 - 29,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: yellow.withOpacity(0.46),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                width: size.width / 2 - 64,
                                height: size.width / 2 - 64,
                                child: products[index].image == null
                                    ? const Icon(Icons.image_not_supported, size: 100, color: Colors.white)
                                    : Image.memory(
                                        base64Decode(products[index].image!),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 100, color: Colors.redAccent),
                                      ),
                              ),
                            ),
                            Flexible(
                              child: Align(
                                alignment: const Alignment(1, 0.5),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 16.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffe0450a).withOpacity(0.51),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    products[index].nom,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: yellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: darkGrey),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(darkGrey, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/search.svg'),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/cart.svg'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PanierScreen(clientId: clientId)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: darkGrey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductEditScreen(produit: _produit)),
              ).then((_) => _refreshProduit());
            },
          ),
        ],
        title: Text(
          _produit.categorie.nom,
          style: const TextStyle(
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            fontSize: 18.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80.0),
                productDisplay,
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 16.0),
                  child: Text(
                    _produit.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                      shadows: shadow,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Container(
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      color: yellow,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: const Center(
                      child: Text(
                        "Détails",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantité : ${_produit.quantite}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        'Fournisseur : ${_produit.fournisseur.nom}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                        ),
                      ),
                      if (_produit.fournisseur.email != null)
                        Text(
                          'Email : ${_produit.fournisseur.email}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                          ),
                        ),
                      if (_produit.description != null) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            shadows: shadow,
                          ),
                        ),
                        Text(
                          _produit.description!,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.6),
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: colorListWidget,
                ),
                const SizedBox(height: 16.0),
                moreProducts,
                const SizedBox(height: 130.0),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                top: 8.0,
                bottom: bottomPadding != 20 ? 20 : bottomPadding,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(255, 255, 255, 0),
                    yellow.withOpacity(0.5),
                    yellow,
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                ),
              ),
              width: size.width,
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  acheterButton,
                  const SizedBox(width: 10),
                  panierButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}