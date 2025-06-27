import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrisisMessageView extends StatefulWidget {
  const CrisisMessageView({super.key});

  @override
  State<CrisisMessageView> createState() => _CrisisMessageViewState();
}

class _CrisisMessageViewState extends State<CrisisMessageView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('crisis_messages').add({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'contact': contactController.text.trim(),
        'message': messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thanks for your feedback!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _formKey.currentState!.reset();
        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        contactController.clear();
        messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send. Try again.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
  appBar: AppBar(
  backgroundColor: const Color(0xff280446),
  elevation: 0,
  centerTitle: true,
  title: const Text(
    'Give Us Feedback',
    style: TextStyle(
      color: Colors.white, // Title color set to white
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // First & Last Name on the same row
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildInput(
                        label: 'First Name',
                        icon: Icons.person,
                        controller: firstNameController,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildInput(
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        controller: lastNameController,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email
              _buildInput(
                label: 'Email',
                icon: Icons.email,
                controller: emailController,
                validator: (val) =>
                    val == null || !val.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 16),

              // Contact
              _buildInput(
                label: 'Contact (Phone or Email)',
                icon: Icons.phone,
                controller: contactController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Message
              _buildInput(
                label: 'Your Feedback Message',
                icon: Icons.message,
                controller: messageController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4EA3AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Submit Feedback',
                          style: TextStyle(
                              color: Colors.white, // Button text color set to white
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    contactController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
