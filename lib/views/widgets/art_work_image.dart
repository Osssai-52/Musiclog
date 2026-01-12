import 'package:flutter/material.dart';

class ArtWorkImage extends StatelessWidget {
  final String image;
  const ArtWorkImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 285,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      )
    );
  }
}
