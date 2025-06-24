import 'produit.dart';

class CommandeProduit {
  final int? id;
  final int? commandeId;
  final int produitId;
  final int quantite;
  final double prixUnitaire;
  final Produit? produit;

  CommandeProduit({
    this.id,
    this.commandeId,
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    this.produit,
  });

  factory CommandeProduit.fromJson(Map<String, dynamic> json) {
    final produitJson = json['produit'];
    return CommandeProduit(
      id: json['id'],
      commandeId: json['commande'] != null ? json['commande']['id'] : null,
      produitId: produitJson != null ? produitJson['id'] : json['produitId'],
      quantite: json['quantite'],
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      produit: produitJson != null ? Produit.fromJson(produitJson) : null,
    );
  }
}
