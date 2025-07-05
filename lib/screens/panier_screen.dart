import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/commande.dart';
import '../models/commande_produit.dart';
import '../services/api_service.dart';
import '../constants.dart';
import 'receipt_page.dart';
import 'login_screen.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  Commande? _commande;
  List<CommandeProduit> _produits = [];
  bool _loading = true;
  bool _isLoadingMap = false;
  final _adresseController = TextEditingController();
  LatLng _selectedLocation = LatLng(36.8065, 10.1815); // Tunis par défaut
  String _paymentMethod = 'Stripe'; // Default payment method
  bool _isPaymentCompleted = false; // Track payment status
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'pk_test_51OHotbIUNFbNVA8jlkNNnNWUGVqaOyjbHcH0s17ZXUROh8NTz8Em3Jo664QWxIRPBjVoH5s88kUAt3QROCnzbxRR00zuiPCnup';
    _loadPanier();
  }

  Future<int> _getClientId() async {
    final clientIdString = await _storage.read(key: 'client_id');
    if (clientIdString == null) {
      throw Exception('Client ID non trouvé. Veuillez vous reconnecter.');
    }
    return int.parse(clientIdString);
  }

  Future<void> _loadPanier() async {
    try {
      final clientId = await _getClientId();
      _commande = await ApiService().fetchPanier(clientId);
      if (_commande != null) {
        _produits = await ApiService().fetchProduitsDuPanier(_commande!.id!);
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur chargement panier : $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      if (e.toString().contains('Client ID non trouvé')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _augmenterQuantite(int commandeProduitId) async {
    try {
      await ApiService().augmenterQuantite(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      _showError("Erreur augmentation quantité : $e");
    }
  }

  Future<void> _diminuerQuantite(int commandeProduitId) async {
    try {
      await ApiService().diminuerQuantite(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      _showError("Erreur diminution quantité : $e");
    }
  }

  Future<void> _supprimerProduit(int commandeProduitId) async {
    try {
      await ApiService().supprimerProduitDuPanier(commandeProduitId);
      await _loadPanier();
    } catch (e) {
      _showError("Erreur suppression produit : $e");
    }
  }

  Future<void> _payer() async {
    if (_paymentMethod == 'Stripe') {
      try {
        final montant = (_total * 100).toInt();
        final clientSecret = await ApiService().createPaymentIntent(montant);
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Gestion Produit',
            style: ThemeMode.light,
          ),
        );
        await Stripe.instance.presentPaymentSheet();
        setState(() {
          _isPaymentCompleted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Paiement réussi"),
            backgroundColor: Color.fromRGBO(236, 60, 3, 1),
          ),
        );
      } catch (e) {
        _showError("Erreur paiement : $e");
      }
    } else {
      setState(() {
        _isPaymentCompleted = true; // For cash on delivery, assume payment is "completed"
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paiement à la livraison sélectionné"),
          backgroundColor: Color.fromRGBO(236, 60, 3, 1),
        ),
      );
    }
  }

  Future<void> _confirmerCommande() async {
    if (_commande == null || _produits.isEmpty) {
      _showError("Panier vide ou non chargé");
      return;
    }
    if (_adresseController.text.isEmpty) {
      _showError("Veuillez entrer une adresse de livraison");
      return;
    }
    if (_paymentMethod == 'Stripe' && !_isPaymentCompleted) {
      _showError("Veuillez effectuer le paiement avant de confirmer");
      return;
    }

    try {
      await ApiService().confirmerCommande(_commande!.id!, _adresseController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Commande confirmée"),
          backgroundColor: Color.fromRGBO(236, 60, 3, 1),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            commande: _commande!,
            produits: _produits,
            adresse: _adresseController.text,
            total: _total,
            paymentMethod: _paymentMethod,
          ),
        ),
      );
    } catch (e) {
      _showError("Erreur confirmation commande : $e");
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'GestionProduit/1.0',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? 'Adresse inconnue';
      }
      return 'Erreur lors de la récupération de l\'adresse';
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  Future<void> _ouvrirCarte() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choisir un emplacement"),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: _selectedLocation,
                  zoom: 13.0,
                  onTap: (tapPosition, point) async {
                    setState(() {
                      _selectedLocation = point;
                      _isLoadingMap = true;
                    });
                    String address = await getAddressFromCoordinates(
                        point.latitude, point.longitude);
                    setState(() {
                      _adresseController.text = address;
                      _isLoadingMap = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isLoadingMap)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Fermer"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  double get _total {
    return _produits.fold(0.0, (sum, cp) => sum + (cp.prixUnitaire * cp.quantite));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildImage(String? base64Image) {
    if (base64Image == null) {
      return const Icon(Icons.image_not_supported, size: 60, color: Colors.white);
    }
    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return const Icon(Icons.broken_image, size: 60, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color yellow = Color(0xFFFBD085);
    const Color darkGrey = Color(0xFF2F2F2F);
    const List<Shadow> shadow = [
      Shadow(
        color: Color.fromRGBO(0, 0, 0, 0.16),
        offset: Offset(0, 3),
        blurRadius: 6.0,
      ),
    ];
    const LinearGradient mainButton = LinearGradient(
      colors: [
        Color.fromRGBO(236, 60, 3, 1),
        Color.fromRGBO(234, 60, 3, 1),
        Color.fromRGBO(216, 78, 16, 1),
      ],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
    );

    Widget totalDisplay = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: darkGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            offset: Offset(0, 3),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Text(
        "Total : ${_total.toStringAsFixed(2)} €",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: "Montserrat",
          fontSize: 24.0,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);

    Widget addressInput = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            offset: Offset(0, 3),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: TextField(
        controller: _adresseController,
        decoration: InputDecoration(
          labelText: "Adresse de livraison",
          labelStyle: const TextStyle(color: darkGrey),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          suffixIcon: IconButton(
            icon: const Icon(Icons.map, color: darkGrey),
            onPressed: _ouvrirCarte,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);

    Widget paymentMethodSelector = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            offset: Offset(0, 3),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _paymentMethod,
        isExpanded: true,
        hint: const Text(
          "Choisir le mode de paiement",
          style: TextStyle(color: darkGrey),
        ),
        items: ['Stripe', 'paiement à la livraison'].map((String method) {
          return DropdownMenuItem<String>(
            value: method,
            child: Text(
              method,
              style: const TextStyle(color: darkGrey, fontSize: 14.0),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _paymentMethod = newValue;
              _isPaymentCompleted = false; // Reset payment status on method change
            });
          }
        },
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 450.ms);

    Widget payerButton = InkWell(
      onTap: _payer,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 3),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Payer maintenant",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms);

    Widget confirmerButton = InkWell(
      onTap: _confirmerCommande,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: mainButton,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              offset: Offset(0, 3),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Confirmer la commande",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);

    return Scaffold(
      backgroundColor: yellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: darkGrey),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(darkGrey, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Votre panier",
          style: TextStyle(
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            fontSize: 18.0,
          ),
        ),
      ),
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
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
          ),
          _loading
              ? const Center(child: CircularProgressIndicator(color: darkGrey))
              : (_commande == null || _produits.isEmpty)
                  ? const Center(
                      child: Text(
                        "Panier vide",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          shadows: shadow,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _produits.length,
                            itemBuilder: (context, index) {
                              final cp = _produits[index];
                              final produit = cp.produit;
                              if (produit == null) return const SizedBox.shrink();

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: yellow.withOpacity(0.46),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.16),
                                      offset: Offset(0, 3),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _buildImage(produit.image),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            produit.nom,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: shadow,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Prix unitaire : ${cp.prixUnitaire.toStringAsFixed(2)} €",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                                                onPressed: () => _diminuerQuantite(cp.id!),
                                              ),
                                              Text(
                                                "${cp.quantite}",
                                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                                                onPressed: () => _augmenterQuantite(cp.id!),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "${(cp.prixUnitaire * cp.quantite).toStringAsFixed(2)} €",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () => _supprimerProduit(cp.id!),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 600.ms, delay: (100 * index).ms);
                            },
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: totalDisplay,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: addressInput,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: paymentMethodSelector,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                payerButton,
                                confirmerButton,
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}