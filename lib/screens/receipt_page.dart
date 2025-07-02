import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/commande.dart';
import '../models/commande_produit.dart';
import '../constants.dart';
import 'product_list_screen.dart';

class ReceiptPage extends StatelessWidget {
  final Commande commande;
  final List<CommandeProduit> produits;
  final String adresse;
  final double total;

  const ReceiptPage({
    super.key,
    required this.commande,
    required this.produits,
    required this.adresse,
    required this.total,
  });

  Widget _buildImage(String? base64Image) {
    if (base64Image == null) {
      return const Icon(Icons.image_not_supported, size: 60, color: Colors.white);
    }
    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return const Icon(Icons.broken_image, size: 60, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color yellow = Color(0xFFFBD085);
    const Color darkGrey = Color(0xFF2F2F2F);
    const List<Shadow> shadow = [
      Shadow(
        color: Color.fromRGBO(0, 0, 0, 0.16),
        offset: Offset(0, 3),
        blurRadius: 6.0,
      ),
    ];
    const List<BoxShadow> boxShadow = [
      BoxShadow(
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

    Widget backButton = InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductListScreen()),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: BorderRadius.circular(9.0),
          boxShadow: boxShadow,
        ),
        child: const Center(
          child: Text(
            "Retour à l'accueil",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);

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
        title: const Text(
          "Reçu de commande",
          style: TextStyle(
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            fontSize: 18.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Commande #${commande.id}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      shadows: shadow,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    "Date: ${DateTime.now().toString().split('.')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: yellow.withOpacity(0.8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Articles",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${produits.length} article${produits.length > 1 ? 's' : ''}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: produits.length,
                    itemBuilder: (context, index) {
                      final cp = produits[index];
                      final produit = cp.produit;
                      if (produit == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: yellow.withOpacity(0.46),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: boxShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildImage(produit.image),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit.nom,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: shadow,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Quantité: ${cp.quantite}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Prix unitaire: ${cp.prixUnitaire.toStringAsFixed(2)} €",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${(cp.prixUnitaire * cp.quantite).toStringAsFixed(2)} €",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: (300 + 100 * index).ms);
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                      ),
                      boxShadow: boxShadow,
                    ),
                    child: Text(
                      "Total : ${total.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Montserrat",
                        fontSize: 24.0,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: boxShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Adresse de livraison",
                          style: TextStyle(
                            color: darkGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          adresse,
                          style: const TextStyle(
                            color: darkGrey,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: boxShadow,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Méthode de paiement",
                          style: TextStyle(
                            color: darkGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Stripe",
                          style: TextStyle(
                            color: darkGrey,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                  const SizedBox(height: 24),
                  Center(child: backButton),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}