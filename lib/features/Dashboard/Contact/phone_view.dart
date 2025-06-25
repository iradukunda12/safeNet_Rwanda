import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneView extends StatefulWidget {
  const PhoneView({super.key});

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> {
  int? selectedCountryIndex;
  bool _isLoading = false;

  final List<Map<String, String>> countries = [
    {'name': 'United States', 'phone': '988', 'description': 'Suicide & Crisis Lifeline'},
    {'name': 'United Kingdom', 'phone': '116 123', 'description': 'Samaritans Crisis Support'},
    {'name': 'Canada', 'phone': '1-833-456-4566', 'description': 'Talk Suicide Canada'},
    {'name': 'Australia', 'phone': '13 11 14', 'description': 'Lifeline Australia'},
    {'name': 'Germany', 'phone': '0800 111 0 111', 'description': 'Telefonseelsorge'},
    {'name': 'France', 'phone': '3114', 'description': 'Numéro National Prévention'},
    {'name': 'Japan', 'phone': '0570-064-556', 'description': 'Japan Suicide Prevention'},
    {'name': 'South Korea', 'phone': '1393', 'description': 'Korea Suicide Prevention'},
  ];

  Future<void> _saveSelection() async {
    if (selectedCountryIndex == null) {
      _showSnackBar('Please select a crisis hotline', Colors.red.shade600);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedCountry = countries[selectedCountryIndex!];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('crisis_country', selectedCountry['name']!);
      await prefs.setString('crisis_phone', selectedCountry['phone']!);

      if (mounted) {
        _showSnackBar('Crisis contact saved successfully!', Colors.green.shade600);
        setState(() {
          selectedCountryIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save. Please try again.', Colors.red.shade600);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

 Widget _buildCountryCard(int index) {
  final country = countries[index];
  final isSelected = selectedCountryIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedCountryIndex = index;
      });
      _saveSelection();
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff4EA3AD) : const Color(0xff8654B0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  country['description']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Right side: phone icon + number
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                country['phone']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        title: const Text(
          'Crisis Hotlines',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Crisis Hotline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your country\'s crisis support line',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Countries List
            Column(
              children: List.generate(countries.length, _buildCountryCard),
            ),

            const SizedBox(height: 20),

            // Info Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency contacts are available 24/7. Your selection is saved locally.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
