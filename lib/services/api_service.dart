import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/produit.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081'; // Pour émulateur Android

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

  // Récupérer tous les utilisateurs (fournisseurs)
  Future<List<Utilisateur>> fetchUtilisateurs() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/utilisateurs'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Utilisateur.fromJson(json)).toList();
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
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/produits/upload'));
      request.fields['nom'] = nom;
      if (description != null) request.fields['description'] = description;
      request.fields['prix'] = prix.toStringAsFixed(2); // Compatible avec BigDecimal
      request.fields['quantite'] = quantite.toString();
      request.fields['categorieId'] = categorieId.toString();
      request.fields['fournisseurId'] = fournisseurId.toString();

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();
      print('Réponse ajout: ${response.statusCode} - $responseBody'); // Log détaillé
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
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
      print('Envoi modif pour ID: $id'); // Log pour vérifier l'ID
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/produits/$id/upload'));
      request.fields['nom'] = nom;
      if (description != null) request.fields['description'] = description;
      request.fields['prix'] = prix.toStringAsFixed(2); // Compatible avec BigDecimal
      request.fields['quantite'] = quantite.toString();
      request.fields['categorieId'] = categorieId.toString();
      request.fields['fournisseurId'] = fournisseurId.toString();

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();
      print('Réponse modif: ${response.statusCode} - $responseBody'); // Log détaillé
      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}