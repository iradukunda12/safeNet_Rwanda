import 'package:flutter/material.dart';
import '../../widgets/Dashboard/bottom_section.dart';
import '../../widgets/Dashboard/top_section.dart';

class DashboardLayoutWithIndex extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final String? fontFamily;

  const DashboardLayoutWithIndex({
    super.key, 
    required this.child, 
    required this.selectedIndex,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    // Better approach - use Theme inherited from parent
    return Scaffold(
      appBar: const TopSection(),
      body: Container(
        color: const Color(0xff280446), // Your purple background
        child: child,
      ),
      bottomSheet: BottomSection(selectedIndex: selectedIndex),
    );
  }
}