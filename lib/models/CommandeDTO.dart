class CommandeDTO {
  final int? id;
  final int? clientId;
  final String? dateCommande;
  final String? statut;
  final double? total;

  CommandeDTO({
    this.id,
    this.clientId,
    this.dateCommande,
    this.statut,
    this.total,
  });

  factory CommandeDTO.fromJson(Map<String, dynamic> json) => CommandeDTO(
        id: json['id'],
        clientId: json['clientId'],
        dateCommande: json['dateCommande'],
        statut: json['statut'],
        total: json['total'] != null ? json['total'].toDouble() : null,
      );
}