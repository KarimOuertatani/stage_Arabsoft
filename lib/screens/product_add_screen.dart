import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import '../models/utilisateur.dart' as user;

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
  user.Utilisateur? _selectedUtilisateur;
  late Future<List<Categorie>> _categoriesFuture;
  late Future<List<user.Utilisateur>> _utilisateursFuture;

  final Color mediumYellow = const Color(0xffF8B250);
  final Color darkGrey = const Color(0xff5E6172);

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService().fetchCategories();
    _utilisateursFuture = ApiService().fetchUtilisateurs();
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
          fournisseurId: _selectedUtilisateur!.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit ajouté avec succès', style: TextStyle(color: darkGrey)),
            backgroundColor: mediumYellow.withOpacity(0.9),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vérifiez tous les champs', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Erreur de chargement de l\'image: $exception');
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: mediumYellow.withOpacity(0.5)),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/back.svg',
                          height: 24,
                          color: darkGrey,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Ajouter un produit',
                        style: TextStyle(
                          color: darkGrey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48), // Espace pour équilibrer
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              labelStyle: TextStyle(color: darkGrey),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow, width: 2),
                              ),
                            ),
                            validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: TextStyle(color: darkGrey),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow, width: 2),
                              ),
                            ),
                            maxLines: 3,
                          ).animate().fadeIn(duration: 600.ms, delay: 250.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _prixController,
                            decoration: InputDecoration(
                              labelText: 'Prix (€)',
                              labelStyle: TextStyle(color: darkGrey),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Prix requis';
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantiteController,
                            decoration: InputDecoration(
                              labelText: 'Quantité',
                              labelStyle: TextStyle(color: darkGrey),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: mediumYellow, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Quantité requise';
                              if (int.tryParse(value) == null || int.parse(value) < 0) {
                                return 'Quantité invalide';
                              }
                              return null;
                            },
                          ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                          const SizedBox(height: 16),
                          FutureBuilder<List<Categorie>>(
                            future: _categoriesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator()).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                              } else if (snapshot.hasError) {
                                return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('Aucune catégorie trouvée', style: TextStyle(color: Colors.grey)).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                              }
                              return DropdownButtonFormField<Categorie>(
                                value: _selectedCategorie,
                                decoration: InputDecoration(
                                  labelText: 'Catégorie',
                                  labelStyle: TextStyle(color: darkGrey),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mediumYellow, width: 2),
                                  ),
                                ),
                                items: snapshot.data!.map((categorie) {
                                  return DropdownMenuItem<Categorie>(
                                    value: categorie,
                                    child: Text(categorie.nom, style: TextStyle(color: darkGrey)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategorie = value;
                                  });
                                },
                                validator: (value) => value == null ? 'Catégorie requise' : null,
                              ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
                            },
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<List<user.Utilisateur>>(
                            future: _utilisateursFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator()).animate().fadeIn(duration: 600.ms, delay: 450.ms);
                              } else if (snapshot.hasError) {
                                return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)).animate().fadeIn(duration: 600.ms, delay: 450.ms);
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('Aucun utilisateur trouvé', style: TextStyle(color: Colors.grey)).animate().fadeIn(duration: 600.ms, delay: 450.ms);
                              }
                              return DropdownButtonFormField<user.Utilisateur>(
                                value: _selectedUtilisateur,
                                decoration: InputDecoration(
                                  labelText: 'Fournisseur',
                                  labelStyle: TextStyle(color: darkGrey),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mediumYellow.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mediumYellow, width: 2),
                                  ),
                                ),
                                items: snapshot.data!.map((utilisateur) {
                                  return DropdownMenuItem<user.Utilisateur>(
                                    value: utilisateur,
                                    child: Text('${utilisateur.nom} ${utilisateur.prenom}', style: TextStyle(color: darkGrey)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUtilisateur = value;
                                  });
                                },
                                validator: (value) => value == null ? 'Fournisseur requis' : null,
                              ).animate().fadeIn(duration: 600.ms, delay: 450.ms);
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              backgroundColor: mediumYellow,
                              shadowColor: Colors.black.withOpacity(0.2),
                              elevation: 4,
                            ),
                            child: Text(
                              'Choisir une image',
                              style: TextStyle(color: darkGrey, fontWeight: FontWeight.bold),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                          if (_image != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Image.file(
                                _image!,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) => Text(
                                  'Erreur image',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 550.ms),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                backgroundColor: mediumYellow,
                                shadowColor: Colors.black.withOpacity(0.2),
                                elevation: 4,
                              ),
                              child: Text(
                                'Ajouter le produit',
                                style: TextStyle(color: darkGrey, fontWeight: FontWeight.bold),
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}