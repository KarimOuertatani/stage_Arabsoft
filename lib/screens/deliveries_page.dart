import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/livraison.dart';
import '../app_properties.dart';

class DeliveriesPage extends StatelessWidget {
  final int clientId;

  const DeliveriesPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mes Livraisons',
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
        child: FutureBuilder<List<Livraison>>(
          future: ApiService().fetchLivraisons(clientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune livraison disponible'));
            }
            final deliveries = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
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
                  child: ListTile(
                    title: Text('Livraison #${delivery.id ?? 'N/A'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Commande: #${delivery.commandeId}'),
                        Text('Adresse: ${delivery.adresseLivraison}'),
                        Text('Statut: ${delivery.statut}'),
                      ],
                    ),
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