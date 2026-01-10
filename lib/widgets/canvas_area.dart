import 'package:flutter/material.dart';

class CanvasArea extends StatelessWidget {
  final Widget child;

  const CanvasArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: child,   // ← AQUÍ SE MUESTRA LA PÁGINA ACTUAL
    );
  }
}