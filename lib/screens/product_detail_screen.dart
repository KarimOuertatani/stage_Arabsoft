import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import 'product_edit_screen.dart';
import '../constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Produit _produit;

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

  Widget _buildImage() {
    if (_produit.image == null) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 100,
          color: kTextLightColor,
        ),
      );
    }
    try {
      final decodedImage = base64Decode(_produit.image!);
      return Hero(
        tag: "${_produit.id}",
        child: Image.memory(
          decodedImage,
          fit: BoxFit.contain,
          height: 200,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.error,
              size: 100,
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    } catch (e) {
      return const Center(
        child: Icon(
          Icons.error,
          size: 100,
          color: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
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
            icon: const Icon(Icons.edit, color: kTextColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductEditScreen(produit: _produit),
                ),
              ).then((_) {
                _refreshProduit();
              });
            },
          ),
          const SizedBox(width: kDefaultPaddin / 2),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.3),
                    padding: EdgeInsets.only(
                      top: size.height * 0.12,
                      left: kDefaultPaddin,
                      right: kDefaultPaddin,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantité : ${_produit.quantite}',
                          style: const TextStyle(color: kTextColor),
                        ),
                        const SizedBox(height: kDefaultPaddin / 2),
                        Text(
                          'Fournisseur : ${_produit.fournisseur.nom}',
                          style: const TextStyle(color: kTextColor),
                        ),
                        if (_produit.fournisseur.email != null) ...[
                          const SizedBox(height: kDefaultPaddin / 4),
                          Text(
                            'Email : ${_produit.fournisseur.email}',
                            style: const TextStyle(color: kTextLightColor),
                          ),
                        ],
                        const SizedBox(height: kDefaultPaddin / 2),
                        if (_produit.description != null) ...[
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: kDefaultPaddin / 4),
                          Text(
                            _produit.description!,
                            style: const TextStyle(height: 1.5, color: kTextColor),
                          ),
                          const SizedBox(height: kDefaultPaddin / 2),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Produit ajouté au panier')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              backgroundColor: const Color(0xFF3D82AE),
                            ),
                            child: const Text(
                              "Acheter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _produit.categorie.nom,
                          style: const TextStyle(color: kTextColor),
                        ),
                        Text(
                          _produit.nom,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kDefaultPaddin),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Prix\n",
                                    style: TextStyle(color: kTextColor),
                                  ),
                                  TextSpan(
                                    text: "${_produit.prix.toStringAsFixed(2)}€",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: kTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: kDefaultPaddin),
                            Expanded(child: _buildImage()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}