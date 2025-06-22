import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/produit.dart';
import '../models/utilisateur.dart' as user;
import '../constants.dart';

class ProductEditScreen extends StatefulWidget {
  final Produit produit;

  const ProductEditScreen({super.key, required this.produit});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
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

  @override
  void initState() {
    super.initState();
    if (widget.produit.id == null) {
      throw Exception('ID du produit invalide');
    }
    print('Modification de produit avec ID: ${widget.produit.id}');
    _nomController.text = widget.produit.nom ?? '';
    _descriptionController.text = widget.produit.description ?? '';
    _prixController.text = widget.produit.prix?.toStringAsFixed(2) ?? '';
    _quantiteController.text = widget.produit.quantite?.toString() ?? '';
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
        await ApiService().updateProduit(
          id: widget.produit.id!,
          nom: _nomController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          prix: double.parse(_prixController.text),
          quantite: int.parse(_quantiteController.text),
          image: _image,
          categorieId: _selectedCategorie!.id,
          fournisseurId: _selectedUtilisateur!.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit modifié avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
        print('Erreur lors de la modification : $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vérifiez tous les champs')),
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
        title: const Text('Modifier un produit'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: kDefaultPaddin),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: kDefaultPaddin),
              TextFormField(
                controller: _prixController,
                decoration: InputDecoration(
                  labelText: 'Prix (€)',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
              ),
              const SizedBox(height: kDefaultPaddin),
              TextFormField(
                controller: _quantiteController,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
              ),
              const SizedBox(height: kDefaultPaddin),
              FutureBuilder<List<Categorie>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: kTextColor);
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.redAccent));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucune catégorie trouvée', style: TextStyle(color: kTextLightColor));
                  }
                  if (_selectedCategorie == null && widget.produit.categorie != null) {
                    _selectedCategorie = snapshot.data!.firstWhere(
                      (cat) => cat.id == widget.produit.categorie!.id,
                      orElse: () => snapshot.data!.first,
                    );
                  }
                  return DropdownButtonFormField<Categorie>(
                    value: _selectedCategorie,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
              const SizedBox(height: kDefaultPaddin),
              FutureBuilder<List<user.Utilisateur>>(
                future: _utilisateursFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: kTextColor);
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.redAccent));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucun utilisateur trouvé', style: TextStyle(color: kTextLightColor));
                  }
                  if (_selectedUtilisateur == null && widget.produit.fournisseur != null) {
                    _selectedUtilisateur = snapshot.data!.firstWhere(
                      (user) => user.id == widget.produit.fournisseur!.id,
                      orElse: () => snapshot.data!.first,
                    );
                  }
                  return DropdownButtonFormField<user.Utilisateur>(
                    value: _selectedUtilisateur,
                    decoration: InputDecoration(
                      labelText: 'Fournisseur',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: snapshot.data!.map((utilisateur) {
                      return DropdownMenuItem<user.Utilisateur>(
                        value: utilisateur,
                        child: Text('${utilisateur.nom} ${utilisateur.prenom}'),
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
              const SizedBox(height: kDefaultPaddin),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: const Color(0xFF3D82AE),
                ),
                child: const Text(
                  'Choisir une image',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
                  child: Image.file(_image!, height: 100, errorBuilder: (context, error, stackTrace) => const Text('Erreur image')),
                ),
              const SizedBox(height: kDefaultPaddin),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: const Color(0xFF3D82AE),
                  ),
                  child: const Text(
                    'Modifier le produit',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}