// lib/features/Dashboard/dashboard_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/themes/colors.dart';
import '../../app/mood_data.dart'; // ✅ Import your Mood model
import 'home/help_cards_section.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood section
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: NepanikarColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // ✅ Replaced animated emoji list with moods from mood_data.dart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moods.map((mood) {
                    return GestureDetector(
                      onTap: () => GoRouter.of(context).go(mood.route),
                      child: Column(
                        children: [
                          Container(
                           
                            decoration: BoxDecoration(
                              color: NepanikarColors.dropdownMenuD,
                              borderRadius: BorderRadius.circular(36),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              mood.assetPath,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mood.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: NepanikarColors.white,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // Help section
                const HelpCardsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
