import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/produit.dart';

class ColorAndSize extends StatelessWidget {
  const ColorAndSize({super.key, required this.produit});

  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Couleurs disponibles"),
              Row(
                children: const <Widget>[
                  ColorDot(color: Color(0xFF356C95), isSelected: true),
                  ColorDot(color: Color(0xFFF8C078), isSelected: false),
                  ColorDot(color: Color(0xFFA29B9B), isSelected: false),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: kTextColor),
              children: [
                const TextSpan(text: "Quantité\n"),
                TextSpan(
                  text: "${produit.quantite} disponibles",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ColorDot reste identique
class ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  
  const ColorDot({
    super.key, 
    required this.color, 
    required this.isSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: kDefaultPaddin / 4,
        right: kDefaultPaddin / 2,
      ),
      padding: const EdgeInsets.all(2.5),
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}