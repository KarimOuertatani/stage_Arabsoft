import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';
import '../app_properties.dart';

class LogoutPage extends StatelessWidget {
  final int clientId;

  const LogoutPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Déconnexion',
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
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Voulez-vous vraiment vous déconnecter ?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff5E6172),
                ),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 24),
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
                child: ListTile(
                  title: const Text('Confirmer la déconnexion'),
                  trailing: Icon(Icons.logout, color: yellow),
                  onTap: () async {
                    try {
                      await ApiService().logout(clientId);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur : $e')),
                      );
                    }
                  },
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
            ],
          ),
        ),
      ),
    );
  }
}