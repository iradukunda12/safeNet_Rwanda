import 'package:flutter/material.dart';
import '../../widgets/Dashboard/bottom_section.dart';     // adjust import paths accordingly
import '../../widgets/Dashboard/top_section.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopSection(),
      body: child,
      bottomSheet: const BottomSection(),
    );
  }
}
