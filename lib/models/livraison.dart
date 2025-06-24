class Livraison {
  final int? id;
  final int commandeId;
  final String adresseLivraison;
  final String statut;

  Livraison({
    this.id,
    required this.commandeId,
    required this.adresseLivraison,
    required this.statut,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) => Livraison(
        id: json['id'],
        commandeId: json['commande']['id'],
        adresseLivraison: json['adresseLivraison'],
        statut: json['statut'],
      );

  Map<String, dynamic> toJson() => {
        'commandeId': commandeId,
        'adresseLivraison': adresseLivraison,
        'statut': statut,
      };
}