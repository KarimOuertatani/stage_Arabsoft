import 'package:flutter/material.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/models/utilisateur.dart' as user;
import 'package:intl/intl.dart';

class AdminProfileScreen extends StatefulWidget {
  final int adminId;

  const AdminProfileScreen({super.key, required this.adminId});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<user.Utilisateur> _utilisateurFuture;
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _numeroTelephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 4;
  static const Color primaryColor = Colors.blueGrey;
  static const Color accentColor = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _utilisateurFuture = ApiService().fetchUtilisateur(widget.adminId);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _formKey.currentState?.reset();
        _errorMessage = null;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService().updateUtilisateur(
        id: widget.adminId,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        numeroTelephone: _numeroTelephoneController.text.isEmpty
            ? null
            : _numeroTelephoneController.text,
        dateNaissance: _dateNaissanceController.text.isEmpty
            ? null
            : DateTime.parse(_dateNaissanceController.text),
        typeUtilisateur: 'ADMIN',
      );
      setState(() {
        _isEditing = false;
        _utilisateurFuture = ApiService().fetchUtilisateur(widget.adminId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin-home', arguments: widget.adminId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin-products', arguments: widget.adminId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/admin-suppliers', arguments: widget.adminId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin-clients', arguments: widget.adminId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/admin-profile', arguments: widget.adminId);
        break;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _numeroTelephoneController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Mon Profil'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<user.Utilisateur>(
          future: _utilisateurFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Aucune donnée utilisateur'));
            }

            final utilisateur = snapshot.data!;
            if (!_isEditing) {
              _nomController.text = utilisateur.nom;
              _prenomController.text = utilisateur.prenom;
              _emailController.text = utilisateur.email;
              _numeroTelephoneController.text = utilisateur.numeroTelephone ?? '';
              _dateNaissanceController.text = utilisateur.dateNaissance != null
                  ? DateFormat('yyyy-MM-dd').format(utilisateur.dateNaissance!)
                  : '';
            }

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  TextFormField(
                    controller: _nomController,
                    decoration: _inputDecoration('Nom'),
                    enabled: _isEditing,
                    validator: (value) =>
                        value!.isEmpty ? 'Veuillez entrer un nom' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    decoration: _inputDecoration('Prénom'),
                    enabled: _isEditing,
                    validator: (value) =>
                        value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Veuillez entrer un email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroTelephoneController,
                    decoration: _inputDecoration('Numéro de téléphone (optionnel)'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateNaissanceController,
                    decoration: _inputDecoration('Date de naissance (YYYY-MM-DD, optionnel)'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value!.isEmpty) return null;
                      try {
                        DateTime.parse(value);
                        return null;
                      } catch (e) {
                        return 'Format de date invalide (YYYY-MM-DD)';
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : (_isEditing ? _saveProfile : _toggleEditMode),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isEditing ? 'Enregistrer' : 'Modifier',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Fournisseurs'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
    );
  }
}