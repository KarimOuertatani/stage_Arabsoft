import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/commande.dart';
import '../models/commande_produit.dart';
import '../services/api_service.dart';

class PanierScreen extends StatefulWidget {
  final int clientId;
  const PanierScreen({super.key, required this.clientId});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  Commande? _commande;
  List<CommandeProduit> _produits = [];
  bool _loading = true;
  final _adresseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPanier();
  }

  Future<void> _loadPanier() async {
    try {
      _commande = await ApiService().fetchPanier(widget.clientId);
      if (_commande != null) {
        _produits = await ApiService().fetchProduitsDuPanier(_commande!.id!);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement du panier : $e")),
      );
    }
  }

  Future<void> _augmenterQuantite(int commandeProduitId) async {
    try {
      await ApiService().augmenterQuantite(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'augmentation de la quantité : $e")),
      );
    }
  }

  Future<void> _diminuerQuantite(int commandeProduitId) async {
    try {
      await ApiService().diminuerQuantite(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la diminution de la quantité : $e")),
      );
    }
  }

  Future<void> _supprimerProduit(int commandeProduitId) async {
    try {
      await ApiService().supprimerProduitDuPanier(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression du produit : $e")),
      );
    }
  }

  Future<void> _confirmerCommande() async {
    if (_commande != null && _adresseController.text.isNotEmpty) {
      await ApiService().confirmerCommande(_commande!.id!, _adresseController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Commande confirmée et livraison créée")),
      );
      Navigator.pop(context);
    }
  }

  double get _total {
    return _produits.fold(
      0.0,
      (sum, cp) => sum + (cp.prixUnitaire * cp.quantite),
    );
  }

  Widget _buildImage(String? base64Image) {
    if (base64Image == null) return const Icon(Icons.image_not_supported, size: 48);
    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Icon(Icons.broken_image, size: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Votre panier")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_commande == null || _produits.isEmpty)
              ? const Center(child: Text("Panier vide"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _produits.length,
                        itemBuilder: (context, index) {
                          final cp = _produits[index];
                          final produit = cp.produit;
                          if (produit == null) return const SizedBox.shrink();

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImage(produit.image),
                              ),
                              title: Text(produit.nom),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Prix unitaire : ${cp.prixUnitaire.toStringAsFixed(2)} €"),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => _diminuerQuantite(cp.id!),
                                      ),
                                      Text("Quantité : ${cp.quantite}"),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _augmenterQuantite(cp.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(cp.prixUnitaire * cp.quantite).toStringAsFixed(2)} €",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _supprimerProduit(cp.id!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total : ${_total.toStringAsFixed(2)} €",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          labelText: "Adresse de livraison",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Confirmer la commande"),
                        onPressed: _confirmerCommande,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color.fromARGB(255, 6, 79, 8),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}