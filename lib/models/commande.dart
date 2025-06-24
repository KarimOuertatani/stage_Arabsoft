class Commande {
  final int? id;
  final int clientId;
  final String statut;
  final double? total;

  Commande({
    this.id,
    required this.clientId,
    required this.statut,
    this.total,
  });

  factory Commande.fromJson(Map<String, dynamic> json) => Commande(
        id: json['id'],
        clientId: json['clientId'],
        statut: json['statut'],
        total: json['total'] != null ? json['total'].toDouble() : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'clientId': clientId,
        'statut': statut,
        if (total != null) 'total': total,
      };
}
