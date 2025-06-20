import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'cart_counter.dart';

class CounterWithFavBtn extends StatelessWidget {
  final VoidCallback onFavPressed;
  
  const CounterWithFavBtn({
    super.key, 
    required this.onFavPressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const CartCounter(),
        IconButton(
          icon: SvgPicture.asset("assets/icons/heart.svg"),
          color: Colors.red,
          onPressed: onFavPressed,
        ),
      ],
    );
  }
}