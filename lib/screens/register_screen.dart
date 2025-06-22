import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import '../constants.dart';
import '../models/utilisateur.dart' as user;
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  String _selectedRole = 'CLIENT';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final utilisateur = await ApiService().register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text,
        numeroTelephone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        dateNaissance: _dateNaissanceController.text.isEmpty
            ? null
            : DateFormat('dd/MM/yyyy').parse(_dateNaissanceController.text),
        typeUtilisateur: _selectedRole,
      );
      if (utilisateur != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie ! Veuillez vous connecter.')),
        );
      }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPaddin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inscription',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                ),
                const SizedBox(height: kDefaultPaddin),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: kDefaultPaddin),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    hintText: 'Nom',
                    prefixIcon: const Icon(Icons.person, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length > 50) {
                      return 'Le nom ne doit pas dépasser 50 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(
                    hintText: 'Prénom',
                    prefixIcon: const Icon(Icons.person, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    if (value.length > 50) {
                      return 'Le prénom ne doit pas dépasser 50 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Numéro de téléphone (optionnel)',
                    prefixIcon: const Icon(Icons.phone, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length > 20) {
                      return 'Le numéro ne doit pas dépasser 20 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                TextFormField(
                  controller: _dateNaissanceController,
                  decoration: InputDecoration(
                    hintText: 'Date de naissance (dd/MM/yyyy, optionnel)',
                    prefixIcon: const Icon(Icons.calendar_today, color: kTextLightColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      try {
                        DateFormat('dd/MM/yyyy').parse(value);
                        return null;
                      } catch (e) {
                        return 'Format de date invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPaddin),
                Text(
                  'S\'inscrire en tant que :',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: kTextColor),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Client'),
                        value: 'CLIENT',
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                        activeColor: const Color(0xFF3D82AE),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Fournisseur'),
                        value: 'FOURNISSEUR',
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                        activeColor: const Color(0xFF3D82AE),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPaddin * 2),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: const Color(0xFF3D82AE),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}