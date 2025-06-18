import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produit.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081'; // Pour Android Emulator

  Future<List<Produit>> fetchProduits() async {
    final response = await http.get(Uri.parse('$baseUrl/api/produits'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des produits');
    }
  }
}