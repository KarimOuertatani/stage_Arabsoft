import 'dart:convert';
import 'dart:io';
import 'package:gestion_produit_flutter/models/commande.dart';
import 'package:gestion_produit_flutter/models/commande_produit.dart';
import 'package:gestion_produit_flutter/models/livraison.dart';
import 'package:http/http.dart' as http;
import '../models/produit.dart';
import '../models/utilisateur.dart' as user;

class ApiService {
  //static const String baseUrl = 'http://10.0.2.2:8081'; // Pour émulateur Android
  static const String baseUrl = 'http://192.168.1.11:8081';

  // Récupérer tous les produits
  Future<List<Produit>> fetchProduits() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/produits'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Produit.fromJson(json)).toList();
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Compter le nombre total de produits
  Future<int> countProduits() async {
    try {
      final produits = await fetchProduits();
      return produits.length;
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Récupérer toutes les catégories
  Future<List<Categorie>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/categories'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Categorie.fromJson(json)).toList();
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<user.Utilisateur>> fetchUtilisateurs() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => user.Utilisateur.fromJson(json)).toList();
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Récupérer les utilisateurs par type (CLIENT ou FOURNISSEUR)
  Future<List<user.Utilisateur>> fetchUtilisateursByType(String type) async {
    try {
      final utilisateurs = await fetchUtilisateurs();
      return utilisateurs.where((u) => u.typeUtilisateur == type).toList();
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Compter le nombre d'utilisateurs par type
  Future<int> countUtilisateursByType(String type) async {
    try {
      final utilisateurs = await fetchUtilisateursByType(type);
      return utilisateurs.length;
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Récupérer un utilisateur par ID
  Future<user.Utilisateur> fetchUtilisateur(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return user.Utilisateur.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Modifier un utilisateur
  Future<void> updateUtilisateur({
    required int id,
    required String nom,
    required String prenom,
    required String email,
    String? numeroTelephone,
    DateTime? dateNaissance,
    required String typeUtilisateur,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/utilisateurs/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'numeroTelephone': numeroTelephone,
          'dateNaissance': dateNaissance?.toIso8601String(),
          'typeUtilisateur': typeUtilisateur,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUtilisateur(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/api/utilisateurs/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Ajouter un produit avec image
  Future<void> addProduit({
    required String nom,
    required String? description,
    required double prix,
    required int quantite,
    required File? image,
    required int categorieId,
    required int fournisseurId,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/produits/upload'));
      request.fields['nom'] = nom;
      if (description != null) request.fields['description'] = description;
      request.fields['prix'] = prix.toStringAsFixed(2);
      request.fields['quantite'] = quantite.toString();
      request.fields['categorieId'] = categorieId.toString();
      request.fields['fournisseurId'] = fournisseurId.toString();

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un produit
  Future<void> deleteProduit(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/api/produits/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Modifier un produit avec image
  Future<void> updateProduit({
    required int id,
    required String nom,
    required String? description,
    required double prix,
    required int quantite,
    required File? image,
    required int categorieId,
    required int fournisseurId,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/produits/$id/upload'));
      request.fields['nom'] = nom;
      if (description != null) request.fields['description'] = description;
      request.fields['prix'] = prix.toStringAsFixed(2);
      request.fields['quantite'] = quantite.toString();
      request.fields['categorieId'] = categorieId.toString();
      request.fields['fournisseurId'] = fournisseurId.toString();

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Connexion d'un utilisateur
  Future<user.Utilisateur?> login(String email, String motDePasse) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/utilisateurs/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'motDePasse': motDePasse,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return user.Utilisateur.fromJson(jsonResponse);
        } else {
          throw Exception('Format de réponse inattendu');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Inscription d'un utilisateur
  Future<user.Utilisateur?> register({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    String? numeroTelephone,
    DateTime? dateNaissance,
    required String typeUtilisateur,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/utilisateurs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'motDePasse': motDePasse,
          'numeroTelephone': numeroTelephone,
          'dateNaissance': dateNaissance?.toIso8601String(),
          'typeUtilisateur': typeUtilisateur,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        return user.Utilisateur.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Erreur : Email déjà utilisé ou données invalides');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<Commande?> fetchPanier(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/commande/panier/$clientId'));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return Commande.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<void> ajouterProduitAuPanier({
    required int clientId,
    required int produitId,
    required int quantite,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/commande/acheter'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'clientId': clientId,
        'produitId': produitId,
        'quantite': quantite,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'ajout au panier');
    }
  }

  Future<List<CommandeProduit>> fetchProduitsDuPanier(int commandeId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/commande-produits/commande/$commandeId'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((json) => CommandeProduit.fromJson(json))
          .toList();
    } else {
      throw Exception('Erreur lors du chargement du panier');
    }
  }

  Future<void> confirmerCommande(int commandeId, String adresse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/commande/confirmer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'commandeId': commandeId,
        'adresseLivraison': adresse,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la confirmation');
    }
  }

  Future<List<Livraison>> fetchLivraisons(int clientId) async {
    return []; // À remplacer plus tard par l'appel réel à l'API
  }

  Future<void> supprimerProduitDuPanier(int commandeProduitId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/commande-produits/$commandeProduitId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Échec suppression produit');
    }
  }

  Future<void> augmenterQuantite(int commandeProduitId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/commande-produits/commande-produits/$commandeProduitId/augmenter'),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec augmentation quantité');
    }
  }

  Future<void> diminuerQuantite(int commandeProduitId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/commande-produits/commande-produits/$commandeProduitId/diminuer'),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec diminution quantité');
    }
  }

  Future<String> createPaymentIntent(int amount) async {
  if (amount <= 0) throw Exception('Montant invalide: $amount');
  final response = await http.post(
    Uri.parse('$baseUrl/api/stripe/create-payment-intent?amount=$amount'), // Correction de '/stripe' à '/api/stripe'
    headers: {'Content-Type': 'application/json'},
  ).timeout(const Duration(seconds: 10));
  print("Réponse status: ${response.statusCode}, body: ${response.body}"); // Débogage
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['clientSecret'] as String;
  } else {
    final data = json.decode(response.body);
    throw Exception('Échec création paiement: ${response.statusCode} - ${data['error'] ?? 'Aucune information'}');
  }
}
Future<List<Commande>> fetchOrders(int clientId) async {
  try {
    final response = await http
        .get(Uri.parse('$baseUrl/api/commande/client/$clientId'))
        .timeout(const Duration(seconds: 20));
    print('Réponse fetchOrders: status=${response.statusCode}, body=${response.body}');
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('Aucune commande trouvée pour clientId: $clientId');
        return [];
      }
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Commande.fromJson(json)).toList();
    } else {
      print('Erreur HTTP: status=${response.statusCode}, body=${response.body}');
      throw Exception('Erreur HTTP : ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur fetchOrders: $e');
    throw Exception('Erreur de connexion à l\'API : $e');
  }
}
Future<List<Livraison>> fetchLivraisons1(int clientId) async {
  try {
    final response = await http
        .get(Uri.parse('$baseUrl/api/livraisons/client/$clientId'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Livraison.fromJson(json)).toList();
    } else {
      throw Exception('Erreur HTTP : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur : $e');
  }
}
Future<void> logout(int clientId) async {
  try {
    final response = await http
        .post(Uri.parse('$baseUrl/api/utilisateurs/logout/$clientId'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Erreur HTTP : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur : $e');
  }
}
Future<List<CommandeProduit>> fetchOrderDetails(int orderId) async {
  try {
    final response = await http
        .get(Uri.parse('$baseUrl/api/commande-produits/commande/$orderId'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CommandeProduit.fromJson(json)).toList();
    } else {
      throw Exception('Erreur HTTP : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur : $e');
  }
}
Future<Livraison> fetchDeliveryDetails(int livraisonId) async {
  try {
    final response = await http
        .get(Uri.parse('$baseUrl/api/livraisons/$livraisonId'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return Livraison.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur HTTP : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur : $e');
  }
}
}