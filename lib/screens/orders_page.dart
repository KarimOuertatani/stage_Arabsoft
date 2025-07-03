import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/commande.dart';
import '../models/commande_produit.dart';
import '../app_properties.dart';

class OrdersPage extends StatelessWidget {
  final int clientId;

  const OrdersPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(
            color: Color(0xff5E6172),
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5E6172)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder<List<Commande>>(
          future: ApiService().fetchOrders(clientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Erreur fetchOrders: ${snapshot.error}'); // Journal de débogage
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print('Aucune commande trouvée pour clientId: $clientId'); // Journal de débogage
              return const Center(child: Text('Aucune commande disponible'));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: transparentYellow,
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text('Commande #${order.id ?? 'N/A'}'),
                    subtitle: Text('Statut: ${order.statut}'),
                    trailing: Text(
                      order.total != null ? '${order.total!.toStringAsFixed(2)} €' : 'N/A',
                    ),
                    children: [
                      FutureBuilder<List<CommandeProduit>>(
                        future: ApiService().fetchOrderDetails(order.id!),
                        builder: (context, detailsSnapshot) {
                          if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            );
                          } else if (detailsSnapshot.hasError) {
                            print('Erreur fetchOrderDetails: ${detailsSnapshot.error}'); // Journal de débogage
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Erreur : ${detailsSnapshot.error}'),
                            );
                          } else if (!detailsSnapshot.hasData || detailsSnapshot.data!.isEmpty) {
                            print('Aucun produit trouvé pour commande: ${order.id}'); // Journal de débogage
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Aucun produit dans cette commande'),
                            );
                          }
                          final produits = detailsSnapshot.data!;
                          return Column(
                            children: produits.map((produit) {
                              return ListTile(
                                leading: produit.produit?.image != null
                                    ? Image.memory(
                                        base64Decode(produit.produit!.image!),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.error,
                                          size: 50,
                                          color: Colors.redAccent,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                title: Text(produit.produit?.nom ?? 'Produit inconnu'),
                                subtitle: Text(
                                  'Quantité: ${produit.quantite} | Prix unitaire: ${produit.prixUnitaire.toStringAsFixed(2)} €',
                                ),
                                trailing: Text(
                                  '${(produit.quantite * produit.prixUnitaire).toStringAsFixed(2)} €',
                                ),
                              ).animate().fadeIn(duration: 600.ms, delay: (100 * produits.indexOf(produit)).ms);
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: (100 * index).ms);
              },
            );
          },
        ),
      ),
    );
  }
}