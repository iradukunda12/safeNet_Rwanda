import 'package:flutter/material.dart';

class MoodMonitoringView extends StatelessWidget {
  const MoodMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Monitoring')),
      body: const Center(child: Text('Mood Monitoring Page')),
    );
  }
}
