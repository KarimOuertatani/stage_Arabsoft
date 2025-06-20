import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/produit.dart';

class ItemCard extends StatelessWidget {
  final Produit produit;
  final VoidCallback press;
  
  const ItemCard({
    super.key, 
    required this.produit, 
    required this.press
  });

  Color get productColor {
    // Logique pour déterminer la couleur basée sur la catégorie
    return const Color(0xFF3D82AE); // Exemple
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(kDefaultPaddin),
              decoration: BoxDecoration(
                color: productColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "${produit.id}",
                child: Image.asset(
                  produit.image ?? 'assets/images/placeholder.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 4),
            child: Text(
              produit.nom,
              style: const TextStyle(color: kTextLightColor),
            ),
          ),
          Text(
            "${produit.prix}€",
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}