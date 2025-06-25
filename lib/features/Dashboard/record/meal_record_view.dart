import 'package:flutter/material.dart';

class MealRecordView extends StatelessWidget {
  const MealRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Record')),
      body: const Center(child: Text('Meal Record Page')),
    );
  }
}
