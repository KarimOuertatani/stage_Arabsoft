class Commande {
  final int? id;
  final int clientId;
  final String statut;

  Commande({this.id, required this.clientId, required this.statut});

  factory Commande.fromJson(Map<String, dynamic> json) => Commande(
        id: json['id'],
        clientId: json['clientId'],
        statut: json['statut'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'clientId': clientId,
        'statut': statut,
      };
}