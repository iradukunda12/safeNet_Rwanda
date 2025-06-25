// lib/features/Dashboard/dashboard_help_view.dart
import 'package:flutter/material.dart';
import './help_cards_section.dart';

class DashboardHelpView extends StatelessWidget {
  const DashboardHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('How can we help you?'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(0.0),
        child: HelpCardsSection(),
      ),
    );
  }
}