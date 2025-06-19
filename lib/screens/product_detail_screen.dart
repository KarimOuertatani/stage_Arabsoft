import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/produit.dart';
import 'product_edit_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.nom),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductEditScreen(produit: produit),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: produit.image != null
                  ? Image.memory(
                      base64Decode(produit.image!),
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 100),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              produit.nom,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prix : ${produit.prix.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text('Quantité : ${produit.quantite}'),
            const SizedBox(height: 8),
            Text('Catégorie : ${produit.categorie.nom}'),
            const SizedBox(height: 8),
            Text('Fournisseur : ${produit.fournisseur.nom}'),
            const SizedBox(height: 8),
            if (produit.description != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(produit.description!),
                  const SizedBox(height: 8),
                ],
              ),
            if (produit.fournisseur.email != null)
              Text('Email fournisseur : ${produit.fournisseur.email}'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produit ajouté au panier')),
                  );
                },
                child: const Text('Acheter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}