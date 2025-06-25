import 'package:flutter/material.dart';

class AuthenticationLayout extends StatelessWidget {
  final Widget child;

  const AuthenticationLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // No AppBar or BottomSection here
    );
  }
}
