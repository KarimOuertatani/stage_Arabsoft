import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import '../constants.dart';
import 'product_edit_screen.dart';
import 'panier_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Produit _produit;
  final int clientId = 1; // TODO: Remplacer par utilisateur connecté si nécessaire

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
      return const Icon(Icons.image_not_supported, size: 100);
    }

    try {
      final decodedImage = base64Decode(_produit.image!);
      return Image.memory(
        decodedImage,
        height: 200,
        fit: BoxFit.contain,
      );
    } catch (e) {
      return const Icon(Icons.error, size: 100, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
            icon: SvgPicture.asset("assets/icons/search.svg"),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset("assets/icons/cart.svg"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PanierScreen(clientId: clientId)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: kTextColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductEditScreen(produit: _produit)),
              ).then((_) => _refreshProduit());
            },
          ),
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
                    padding: const EdgeInsets.all(kDefaultPaddin),
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
                        Text('Quantité : ${_produit.quantite}'),
                        Text('Fournisseur : ${_produit.fournisseur.nom}'),
                        if (_produit.fournisseur.email != null)
                          Text('Email : ${_produit.fournisseur.email}'),
                        if (_produit.description != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(_produit.description!),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _acheterProduit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D82AE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text("Acheter",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PanierScreen(clientId: clientId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text("Voir Panier",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_produit.categorie.nom),
                        Text(
                          _produit.nom,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
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
                                    text:
                                        "${_produit.prix.toStringAsFixed(2)} €",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            color: kTextColor,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
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
