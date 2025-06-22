class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? numeroTelephone;
  final DateTime? dateNaissance;
  final String typeUtilisateur;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.numeroTelephone,
    this.dateNaissance,
    required this.typeUtilisateur,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      numeroTelephone: json['numeroTelephone'],
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.parse(json['dateNaissance'])
          : null,
      typeUtilisateur: json['typeUtilisateur'],
    );
  }
}