import 'package:flutter/material.dart';

class CanvasArea extends StatelessWidget {
  final Widget child;

  const CanvasArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0D1117),
      child: child,   // ← AQUÍ SE MUESTRA LA PÁGINA ACTUAL
    );
  }
}