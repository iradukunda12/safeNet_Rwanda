import 'package:flutter/material.dart';

class MySleepView extends StatelessWidget {
  const MySleepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Sleep')),
      body: const Center(child: Text('My Sleep Page')),
    );
  }
}
