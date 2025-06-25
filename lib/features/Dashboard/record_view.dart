import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordView extends StatefulWidget {
  const RecordView({super.key});

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  int activeIndex = 0;

  final List<_RecordLink> records = [
    _RecordLink(icon: Icons.mood, title: 'Mood Monitoring'),
    _RecordLink(icon: Icons.bedtime, title: 'My Sleep'),
    _RecordLink(icon: Icons.book, title: 'Diary'),
    _RecordLink(icon: Icons.timeline, title: 'Journey'),
    _RecordLink(icon: Icons.restaurant_menu, title: 'Meal Record'),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xff491475);
    final activeColor = const Color(0xff4EA3AD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Records',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: records.asMap().entries.map((entry) {
            int idx = entry.key;
            _RecordLink record = entry.value;
            bool isActive = idx == activeIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  activeIndex = idx;
                });

                // Define your new routes here
                final routes = [
                  '/records/mood-monitoring',
                  '/records/my-sleep',
                  '/records/diary',
                  '/records/journey',
                  '/records/meal-record',
                ];

                GoRouter.of(context).go(routes[idx]);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? activeColor : Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(record.icon, color: Colors.white, size: 28),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        record.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecordLink {
  final IconData icon;
  final String title;

  _RecordLink({
    required this.icon,
    required this.title,
  });
}
