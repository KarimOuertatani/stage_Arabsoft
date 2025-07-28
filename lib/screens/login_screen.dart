import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_produit_flutter/screens/SupplierProductListScreen.dart';
import 'package:gestion_produit_flutter/screens/product_list_screen.dart';
import 'package:gestion_produit_flutter/screens/supplier_my_product_list_screen.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/register_screen.dart';
import 'package:gestion_produit_flutter/screens/ResetPasswordScreen.dart'; // Added import
import '../constants.dart';
import '../app_properties.dart';
import '../models/utilisateur.dart' as user;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Vérifier si un token existe dans le stockage sécurisé
      final token = await _storage.read(key: 'jwt_token');
      print('Token trouvé au démarrage : $token');
      if (token != null) {
        // Appeler l'API pour vérifier la validité du token et récupérer l'utilisateur
        final utilisateur = await ApiService().fetchCurrentUser();
        print('Utilisateur récupéré : ${utilisateur.typeUtilisateur}, ID: ${utilisateur.id}');
        // Stocker l'ID de l'utilisateur pour tous les types (CLIENT et FOURNISSEUR)
        await _storage.write(key: 'client_id', value: utilisateur.id.toString());
        if (utilisateur.typeUtilisateur == 'CLIENT') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProductListScreen()),
            );
          }
        } else if (utilisateur.typeUtilisateur == 'FOURNISSEUR') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SupplierProductListScreen()),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Type d\'utilisateur inconnu';
            _isLoading = false;
          });
        }
      } else {
        // Aucun token, afficher l'écran de connexion
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur dans _checkAuth : $e');
      // Supprimer les tokens uniquement si l'erreur est 401 (token invalide)
      if (e.toString().contains('Non autorisé') || e.toString().contains('401')) {
        await _storage.delete(key: 'jwt_token');
        await _storage.delete(key: 'client_id');
        setState(() {
          _errorMessage = 'Session expirée, veuillez vous reconnecter';
          _isLoading = false;
        });
      } else {
        // Ne pas supprimer les tokens pour les erreurs temporaires (ex. serveur non disponible)
        setState(() {
          _errorMessage = 'Erreur de connexion au serveur, veuillez réessayer';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('Token après connexion : $token');
      if (token != null) {
        final utilisateur = await ApiService().fetchCurrentUser();
        print('Utilisateur après connexion : ${utilisateur.typeUtilisateur}, ID: ${utilisateur.id}');
        // Stocker l'ID de l'utilisateur pour tous les types (CLIENT et FOURNISSEUR)
        await _storage.write(key: 'client_id', value: utilisateur.id.toString());
        if (utilisateur.typeUtilisateur == 'CLIENT') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductListScreen(),
              ),
            );
          }
        } else if (utilisateur.typeUtilisateur == 'FOURNISSEUR') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SupplierProductListScreen(),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Type d\'utilisateur inconnu';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur : token non reçu';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur dans _login : $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget title = const Text(
      'Connexion',
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
        'Connectez-vous à votre compte',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);

    Widget loginButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 40,
      child: InkWell(
        onTap: _isLoading ? null : _login,
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 80,
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
                    "Se connecter",
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

    Widget loginForm = Container(
      height: 240,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);

    Widget forgotPassword = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Mot de passe oublié ? ',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Color.fromRGBO(255, 255, 255, 0.5),
              fontSize: 14.0,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
              );
            },
            child: const Text(
              'Réinitialiser',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms);

    Widget registerLink = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Pas de compte ? ',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Color.fromRGBO(255, 255, 255, 0.5),
              fontSize: 14.0,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text(
              'S\'inscrire',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);

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
                Stack(
                  children: [
                    loginForm,
                    loginButton,
                  ],
                ),
                const Spacer(flex: 2),
                forgotPassword,
                registerLink,
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