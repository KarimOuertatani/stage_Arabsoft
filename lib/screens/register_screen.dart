import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPaddin),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kTextLightColor),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
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
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                ),
                const SizedBox(height: kDefaultPaddin),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                buildTextField(
                  controller: _nomController,
                  hint: 'Nom',
                  icon: Icons.person,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer votre nom'
                      : (value.length > 50 ? 'Maximum 50 caractères' : null),
                ),
                buildTextField(
                  controller: _prenomController,
                  hint: 'Prénom',
                  icon: Icons.person,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer votre prénom'
                      : (value.length > 50 ? 'Maximum 50 caractères' : null),
                ),
                buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email,
                  type: TextInputType.emailAddress,
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
                buildTextField(
                  controller: _passwordController,
                  hint: 'Mot de passe',
                  icon: Icons.lock,
                  obscure: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer un mot de passe'
                      : null,
                ),
                buildTextField(
                  controller: _phoneController,
                  hint: 'Téléphone (optionnel)',
                  icon: Icons.phone,
                  type: TextInputType.phone,
                  validator: (value) =>
                      value != null && value.length > 20 ? 'Max 20 caractères' : null,
                ),
                buildTextField(
                  controller: _dateNaissanceController,
                  hint: 'Date de naissance',
                  icon: Icons.calendar_today,
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
                const SizedBox(height: kDefaultPaddin / 2),
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
