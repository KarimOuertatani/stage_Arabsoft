import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../app_properties.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
  String _selectedCountryCode = '+216';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Register the user
      final utilisateur = await ApiService().register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text,
        numeroTelephone: _phoneController.text.trim().isEmpty
            ? null
            : '$_selectedCountryCode${_phoneController.text.trim()}',
        dateNaissance: _dateNaissanceController.text.isEmpty
            ? null
            : DateFormat('dd/MM/yyyy').parse(_dateNaissanceController.text),
        typeUtilisateur: _selectedRole,
      );

      if (utilisateur != null) {
        // Log in the user to obtain a JWT token
        await ApiService().login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Try to create a secret code
        String? codeSecret;
        try {
          final codeSecretClient = await ApiService().createSecretCode(
            utilisateur.id,
          );
          codeSecret = codeSecretClient.codeSecret;
        } catch (e) {
          print('Failed to create secret code: $e');
          // Continue with navigation even if secret code creation fails
          codeSecret = null;
        }

        // Show success message with or without secret code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              codeSecret != null
                  ? 'Inscription réussie ! Votre code secret est : $codeSecret'
                  : 'Inscription réussie ! Veuillez vérifier votre code secret ultérieurement.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Erreur : utilisateur non créé';
        });
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(236, 60, 3, 1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(236, 60, 3, 1),
              ),
            ),
          ),
          child: child!,
        );
      },
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
    Widget title = const Text(
      'Inscription',
      style: TextStyle(
        color: Colors.white,
        fontSize: 34.0,
        fontWeight: FontWeight.bold,
        shadows: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0, 5),
            blurRadius: 10.0,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);

    Widget subTitle = const Padding(
      padding: EdgeInsets.only(right: 56.0),
      child: Text(
        'Créez votre compte pour commencer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);

    Widget registerButton = Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: InkWell(
        onTap: _isLoading ? null : _register,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(236, 60, 3, 1),
                Color.fromRGBO(234, 60, 3, 1),
                Color.fromRGBO(216, 78, 16, 1),
              ],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                offset: Offset(0, 5),
                blurRadius: 10.0,
              ),
            ],
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "S'inscrire",
                    style: TextStyle(
                      color: Color(0xfffefefe),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0,
                    ),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);

    Widget registerForm = Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 32.0, right: 12.0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _nomController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Nom',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer votre nom'
                    : (value.length > 50 ? 'Maximum 50 caractères' : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _prenomController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Prénom',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer votre prénom'
                    : (value.length > 50 ? 'Maximum 50 caractères' : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/email.svg',
                      height: 20,
                      color: darkGrey,
                    ),
                  ),
                  border: InputBorder.none,
                ),
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/password.svg',
                      height: 20,
                      color: darkGrey,
                    ),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un mot de passe'
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountryCodePicker(
                    initialSelection: 'TN',
                    favorite: ['+216', 'TN', '+33', 'FR'],
                    onChanged: (code) {
                      setState(() {
                        _selectedCountryCode = code.dialCode ?? '+216';
                      });
                    },
                    textStyle: const TextStyle(fontSize: 16.0, color: darkGrey),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _phoneController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: 'Téléphone (optionnel)',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value != null && value.length > 20 ? 'Max 20 caractères' : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _dateNaissanceController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: 'Date de naissance (optionnel)',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: darkGrey,
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
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
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);

    Widget roleSelection = Padding(
      padding: const EdgeInsets.only(right: 28.0, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'S\'inscrire en tant que :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'CLIENT',
                label: Text('Client'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment<String>(
                value: 'FOURNISSEUR',
                label: Text('Fournisseur'),
                icon: Icon(Icons.store),
              ),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedRole = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              foregroundColor: Colors.white,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: Color.fromRGBO(236, 60, 3, 1),
              backgroundColor: Colors.white.withOpacity(0.2),
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms);

    Widget errorMessage = _errorMessage != null
        ? Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms)
        : const SizedBox.shrink();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: transparentYellow),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(flex: 3),
                title,
                const Spacer(),
                subTitle,
                const Spacer(flex: 2),
                errorMessage,
                registerForm,
                registerButton,
                roleSelection,
                const Spacer(flex: 2),
              ],
            ),
          ),
          Positioned(
            top: 35,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          ),
        ],
      ),
    );
  }
}