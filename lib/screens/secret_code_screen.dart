import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gestion_produit_flutter/services/api_service.dart';
import 'package:gestion_produit_flutter/screens/login_screen.dart';
import '../app_properties.dart';

class SecretCodeScreen extends StatefulWidget {
  const SecretCodeScreen({super.key});

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  final _storage = const FlutterSecureStorage();
  String? _secretCode;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSecretCode();
  }

  Future<void> _fetchSecretCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final utilisateurIdStr = await _storage.read(key: 'client_id');
      if (utilisateurIdStr == null) {
        throw Exception('Utilisateur non trouvé');
      }
      final utilisateurId = int.parse(utilisateurIdStr);

      final response = await ApiService().getSecretCode(utilisateurId);
      print('API Response: $response'); // Debug log
      if (response == null) {
        throw Exception('Réponse de l\'API est null');
      }
      setState(() {
        _secretCode = ['codeSecret'].toString();
        if (_secretCode == null) {
          _errorMessage = 'Code secret non trouvé dans la réponse';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error fetching secret code: $e'); // Debug log
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget title = const Text(
      'Code Secret',
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
        'Votre code secret pour sécuriser votre compte',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);

    Widget codeDisplay = Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    _secretCode ?? 'Non disponible',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(236, 60, 3, 1),
                    ),
                  ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);

    Widget retryButton = _errorMessage != null
        ? Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: InkWell(
              onTap: _fetchSecretCode,
              child: Container(
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
                child: const Center(
                  child: Text(
                    'Réessayer',
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
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms)
        : const SizedBox.shrink();

    Widget continueButton = Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: InkWell(
        onTap: _isLoading
            ? null
            : () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
        child: Container(
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
                    'Continuer',
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
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);

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
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                title,
                const Spacer(),
                subTitle,
                const Spacer(flex: 2),
                codeDisplay,
                if (_errorMessage != null) retryButton,
                continueButton,
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