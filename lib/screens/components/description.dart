import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/produit.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.produit});

  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Text(
        produit.description ?? 'Aucune description disponible',
        style: const TextStyle(height: 1.5),
      ),
    );
  }
}