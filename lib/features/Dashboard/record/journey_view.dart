import 'package:flutter/material.dart';

class JourneyView extends StatelessWidget {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journey')),
      body: const Center(child: Text('Journey Page')),
    );
  }
}
