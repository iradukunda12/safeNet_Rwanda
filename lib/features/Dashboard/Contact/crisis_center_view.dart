import 'package:flutter/material.dart';

class CrisisCenterView extends StatelessWidget {
  const CrisisCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crisis Center')),
      body: const Center(child: Text('Crisis Center info and support here')),
    );
  }
}
