import 'utilisateur.dart';

class CodeSecretClient {
  final int id;
  final String codeSecret;
  final Utilisateur utilisateur;

  CodeSecretClient({
    required this.id,
    required this.codeSecret,
    required this.utilisateur,
  });

  factory CodeSecretClient.fromJson(Map<String, dynamic> json) {
    return CodeSecretClient(
      id: json['id'],
      codeSecret: json['codeSecret'],
      utilisateur: Utilisateur.fromJson(json['utilisateur']),
    );
  }
}