import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/produit.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _quantiteController = TextEditingController();
  File? _image;
  Categorie? _selectedCategorie;
  Utilisateur? _selectedUtilisateur; // Changé de _selectedFournisseur
  late Future<List<Categorie>> _categoriesFuture;
  late Future<List<Utilisateur>> _utilisateursFuture; // Changé de _fournisseursFuture

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService().fetchCategories();
    _utilisateursFuture = ApiService().fetchUtilisateurs(); // Changé
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategorie != null && _selectedUtilisateur != null) {
      try {
        await ApiService().addProduit(
          nom: _nomController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          prix: double.parse(_prixController.text),
          quantite: int.parse(_quantiteController.text),
          image: _image,
          categorieId: _selectedCategorie!.id,
          fournisseurId: _selectedUtilisateur!.id, // Utilise l'ID de l'utilisateur
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vérifie tous les champs')),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Nom requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix (€)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Prix requis';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantiteController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Quantité requise';
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Quantité invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Categorie>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucune catégorie trouvée');
                  }
                  return DropdownButtonFormField<Categorie>(
                    value: _selectedCategorie,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                    items: snapshot.data!.map((categorie) {
                      return DropdownMenuItem<Categorie>(
                        value: categorie,
                        child: Text(categorie.nom),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategorie = value;
                      });
                    },
                    validator: (value) => value == null ? 'Catégorie requise' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Utilisateur>>(
                future: _utilisateursFuture, // Utilise la nouvelle méthode
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucun utilisateur trouvé');
                  }
                  return DropdownButtonFormField<Utilisateur>(
                    value: _selectedUtilisateur,
                    decoration: const InputDecoration(labelText: 'Fournisseur'),
                    items: snapshot.data!.map((utilisateur) {
                      return DropdownMenuItem<Utilisateur>(
                        value: utilisateur,
                        child: Text(utilisateur.nom),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUtilisateur = value;
                      });
                    },
                    validator: (value) => value == null ? 'Fournisseur requis' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Choisir une image'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(_image!, height: 100),
                ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Ajouter le produit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}