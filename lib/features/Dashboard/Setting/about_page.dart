import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  static const _appDescription = '''
Nepanikar is a modern app designed to enhance your daily productivity with seamless features, intuitive design, and reliable performance. 

It provides you with tools and settings customization to optimize your experience and keep everything organized effortlessly.

Explore the app to discover how Nepanikar can simplify your life and keep you connected to what matters most.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nepanikar',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xff8654B0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _appDescription,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
