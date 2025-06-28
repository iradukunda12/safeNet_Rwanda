import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  int activeIndex = 0;

  final List<_ContactLink> links = [
    _ContactLink(icon: Icons.feedback_outlined, title: 'Feedback '),
    _ContactLink(icon: Icons.vibration, title: 'Phone'),
    _ContactLink(icon: Icons.forum_outlined, title: 'Community Forum'),

    _ContactLink(icon: Icons.message, title: 'Chat'),
    _ContactLink(icon: Icons.mic, title: 'Speech to Text'),

  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff491475);
    const activeColor = Color(0xff4EA3AD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contact',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24,left:20), // Reduced top margin
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: links.asMap().entries.map((entry) {
            int idx = entry.key;
            _ContactLink link = entry.value;
            bool isActive = idx == activeIndex;

            return GestureDetector(
            onTap: () {
  setState(() {
    activeIndex = idx;
  });

  // Navigate to proper route
  final routes = [
    '/dashboard/contact/crisis-message',
    '/dashboard/contact/phone',
    '/dashboard/contact/crisis-center',
    '/dashboard/contact/chat',
    '/dashboard/contact/speech', // My Contact
  ];

GoRouter.of(context).go(routes[idx]);

},

              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.only(bottom: 12), // Spacing between cards
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
                    Icon(link.icon, color: Colors.white, size: 28),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        link.title,
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

class _ContactLink {
  final IconData icon;
  final String title;

  _ContactLink({
    required this.icon,
    required this.title,
  });
}
