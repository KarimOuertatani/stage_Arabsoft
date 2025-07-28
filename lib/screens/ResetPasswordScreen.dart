import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gestion_produit_flutter/app_properties.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import '../constants.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _codeSecretController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ApiService().resetPassword(
        email: _emailController.text.trim(),
        dateNaissance: _dateNaissanceController.text.trim(),
        codeSecret: _codeSecretController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      setState(() {
        _successMessage = 'Mot de passe réinitialisé avec succès !';
        _isLoading = false;
      });
      // Rediriger vers la page de connexion après 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _dateNaissanceController.dispose();
    _codeSecretController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget title = const Text(
      'Réinitialiser le mot de passe',
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
        'Entrez vos informations pour réinitialiser votre mot de passe',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);

    Widget resetButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 40,
      child: InkWell(
        onTap: _isLoading ? null : _resetPassword,
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                    "Réinitialiser",
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

    Widget resetForm = Container(
      height: 360,
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
                controller: _dateNaissanceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.datetime,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Date de naissance (YYYY-MM-DD)',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      height: 20,
                      color: darkGrey,
                    ),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre date de naissance';
                  }
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                    return 'Format : YYYY-MM-DD';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (e) {
                    return 'Date invalide';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _codeSecretController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Code secret',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/lock.svg',
                      height: 20,
                      color: darkGrey,
                    ),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre code secret';
                  }
                  if (value.length > 10) {
                    return 'Code secret trop long';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _newPasswordController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Nouveau mot de passe',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nouveau mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);

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
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                Stack(
                  children: [
                    resetForm,
                    resetButton,
                  ],
                ),
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