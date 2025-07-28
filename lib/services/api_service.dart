import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_produit_flutter/models/code_secret_client.dart';
import 'package:gestion_produit_flutter/models/commande.dart';
import 'package:gestion_produit_flutter/models/commande_produit.dart';
import 'package:gestion_produit_flutter/models/livraison.dart';
import 'package:http/http.dart' as http;
import '../models/produit.dart';
import '../models/utilisateur.dart' as user;

class ApiService {
  static const String baseUrl = 'http://192.168.1.12:8081';
  static const _storage = FlutterSecureStorage();

  // Helper method to get the JWT token from secure storage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Helper method to add Authorization header to requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fetch the current authenticated user
  Future<user.Utilisateur> fetchCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs/current'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return user.Utilisateur.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Récupérer tous les produits
  Future<List<Produit>> fetchProduits() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/produits'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Produit.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
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
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/categories'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Categorie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
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
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => user.Utilisateur.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
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
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs/$id'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return user.Utilisateur.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
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
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/utilisateurs/$id'),
        headers: headers,
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'numeroTelephone': numeroTelephone,
          'dateNaissance': dateNaissance?.toIso8601String(),
          'typeUtilisateur': typeUtilisateur,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUtilisateur(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/api/utilisateurs/$id'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
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
      final headers = await _getHeaders();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/produits/upload'));
      request.headers.addAll(headers);
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un produit
  Future<void> deleteProduit(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/api/produits/$id'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
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
      final headers = await _getHeaders();
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/produits/$id/upload'));
      request.headers.addAll(headers);
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
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Connexion d'un utilisateur
  Future<String?> login(String email, String motDePasse) async {
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
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          return token;
        } else {
          throw Exception('Token non trouvé dans la réponse');
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

  // Déconnexion d'un utilisateur
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'client_id');
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion : $e');
    }
  }

  Future<Commande?> fetchPanier(int clientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/commande/panier/$clientId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Commande.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      }
      return null;
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> ajouterProduitAuPanier({
    required int clientId,
    required int produitId,
    required int quantite,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/commande/acheter'),
        headers: headers,
        body: jsonEncode({
          'clientId': clientId,
          'produitId': produitId,
          'quantite': quantite,
        }),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors de l\'ajout au panier : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<List<CommandeProduit>> fetchProduitsDuPanier(int commandeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/commande-produits/commande/$commandeId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((json) => CommandeProduit.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors du chargement du panier : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> confirmerCommande(int commandeId, String adresse) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/commande/confirmer'),
        headers: headers,
        body: jsonEncode({
          'commandeId': commandeId,
          'adresseLivraison': adresse,
        }),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors de la confirmation : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<List<Livraison>> fetchLivraisons(int clientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/livraisons/client/$clientId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Livraison.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> supprimerProduitDuPanier(int commandeProduitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/api/commande-produits/$commandeProduitId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Échec suppression produit : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> augmenterQuantite(int commandeProduitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/commande-produits/commande-produits/$commandeProduitId/augmenter'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Échec augmentation quantité : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> diminuerQuantite(int commandeProduitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/commande-produits/commande-produits/$commandeProduitId/diminuer'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Échec diminution quantité : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<String> createPaymentIntent(int amount) async {
    try {
      if (amount <= 0) throw Exception('Montant invalide: $amount');
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/stripe/create-payment-intent?amount=$amount'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));
      print("Réponse status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['clientSecret'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        final data = jsonDecode(response.body);
        throw Exception('Échec création paiement: ${response.statusCode} - ${data['error'] ?? 'Aucune information'}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<List<Commande>> fetchOrders(int clientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/commande/client/$clientId'), headers: headers)
          .timeout(const Duration(seconds: 20));
      print('Réponse fetchOrders: status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Aucune commande trouvée pour clientId: $clientId');
          return [];
        }
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Commande.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
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
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/livraisons/client/$clientId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Livraison.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<List<CommandeProduit>> fetchOrderDetails(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/commande-produits/commande/$orderId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CommandeProduit.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<Livraison> fetchDeliveryDetails(int livraisonId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/api/livraisons/$livraisonId'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return Livraison.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // Replace the existing createSecretCode method in ApiService class
  Future<CodeSecretClient> createSecretCode(int utilisateurId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/code-secret/create'),
            headers: headers,
            body: jsonEncode(utilisateurId),
          )
          .timeout(const Duration(seconds: 5));
      print('createSecretCode: status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200) {
        return CodeSecretClient.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('createSecretCode error: $e');
      throw Exception('Erreur lors de la création du code secret : $e');
    }
  }

    Future<CodeSecretClient?> getSecretCode(int utilisateurId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/code-secret/$utilisateurId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));
      print('getSecretCode: status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200) {
        return CodeSecretClient.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        print('No secret code found for utilisateurId: $utilisateurId');
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('getSecretCode error: $e');
      throw Exception('Erreur lors de la récupération du code secret : $e');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String dateNaissance,
    required String codeSecret,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/utilisateurs/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'dateNaissance': dateNaissance,
          'codeSecret': codeSecret,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Email, date de naissance ou code secret incorrect');
      } else if (response.statusCode == 400) {
        throw Exception('Données invalides');
      } else {
        throw Exception('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }
}