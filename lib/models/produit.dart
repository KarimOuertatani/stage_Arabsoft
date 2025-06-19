class Produit {
  final int id;
  final String nom;
  final String? description;
  final double prix;
  final int quantite;
  final String? image;
  final Categorie categorie;
  final Utilisateur fournisseur;

  Produit({
    required this.id,
    required this.nom,
    this.description,
    required this.prix,
    required this.quantite,
    this.image,
    required this.categorie,
    required this.fournisseur,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      prix: (json['prix'] is int) ? (json['prix'] as int).toDouble() : json['prix'].toDouble(),
      quantite: json['quantite'],
      image: json['image'],
      categorie: Categorie.fromJson(json['categorie']),
      fournisseur: Utilisateur.fromJson(json['fournisseur']),
    );
  }
}

class Categorie {
  final int id;
  final String nom;

  Categorie({required this.id, required this.nom});

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      nom: json['nom'],
    );
  }
}

class Utilisateur {
  final int id;
  final String nom;
  final String? prenom;
  final String? email;
  final String? numeroTelephone;
  final String? dateNaissance;
  final String? typeUtilisateur;

  Utilisateur({
    required this.id,
    required this.nom,
    this.prenom,
    this.email,
    this.numeroTelephone,
    this.dateNaissance,
    this.typeUtilisateur,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'],
      email: json['email'],
      numeroTelephone: json['numeroTelephone'],
      dateNaissance: json['dateNaissance'],
      typeUtilisateur: json['typeUtilisateur'],
    );
  }
}