import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import '../app_properties.dart';

class VerifyCodeScreen extends StatefulWidget {
  final int utilisateurId;

  const VerifyCodeScreen({super.key, required this.utilisateurId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await ApiService().verifySecretCode(
        utilisateurId: widget.utilisateurId,
        codeSecret: _codeController.text.trim(),
      );

      if (isValid) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code vérifié avec succès !')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Code secret invalide';
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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                const Text(
                  'Vérification du Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34.0,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const Spacer(),
                const Text(
                  'Entrez votre code secret pour vérifier votre compte',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                const Spacer(flex: 2),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: 'Code secret',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer le code secret'
                          : (value.length != 6 ? 'Le code doit contenir 6 chiffres' : null),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: InkWell(
                    onTap: _isLoading ? null : _verifyCode,
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
                                'Vérifier',
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
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
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