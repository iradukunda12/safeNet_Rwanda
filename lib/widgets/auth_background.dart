// lib/widgets/auth_background.dart
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;

  const AuthBackground({
    super.key,
    required this.child,
    this.gradientColors,
    this.gradientStops,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
            const Color(0xFFf093fb),
            const Color(0xFFf5576c),
          ],
          stops: gradientStops ?? [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}