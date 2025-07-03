import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gestion_produit_flutter/app_properties.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import '../services/api_service.dart';
import '../models/utilisateur.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final int clientId;

  const ProfilePage({super.key, required this.clientId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Future<Utilisateur> _utilisateurFuture;
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _numeroTelephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _utilisateurFuture = ApiService().fetchUtilisateur(widget.clientId);
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
        id: widget.clientId,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        numeroTelephone: _numeroTelephoneController.text.isEmpty
            ? null
            : _numeroTelephoneController.text,
        dateNaissance: _dateNaissanceController.text.isEmpty
            ? null
            : DateTime.parse(_dateNaissanceController.text),
        typeUtilisateur: 'CLIENT',
      );
      setState(() {
        _isEditing = false;
        _utilisateurFuture = ApiService().fetchUtilisateur(widget.clientId);
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

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _numeroTelephoneController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non spécifié';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Color(0xff5E6172),
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5E6172)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xff5E6172)),
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
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
            child: FutureBuilder<Utilisateur>(
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
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      CircleAvatar(
                        maxRadius: 48,
                        backgroundImage: const AssetImage('assets/background.jpg'),
                      ).animate().fadeIn(duration: 600.ms),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${utilisateur.prenom} ${utilisateur.nom}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Color(0xff5E6172),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: transparentYellow,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nomController,
                              decoration: _inputDecoration('Nom'),
                              enabled: _isEditing,
                              validator: (value) =>
                                  value!.isEmpty ? 'Veuillez entrer un nom' : null,
                            ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _prenomController,
                              decoration: _inputDecoration('Prénom'),
                              enabled: _isEditing,
                              validator: (value) =>
                                  value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
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
                            ).animate().fadeIn(duration: 600.ms, delay: 250.ms),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _numeroTelephoneController,
                              decoration: _inputDecoration('Numéro de téléphone (optionnel)'),
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
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
                            ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : (_isEditing ? _saveProfile : _toggleEditMode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yellow,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 450.ms),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: transparentYellow,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: yellow, width: 2),
      ),
    );
  }
}