// lib/views/signup_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../../../widgets/auth_background.dart';
import '../../../widgets/auth_header.dart';
import '../../../widgets/auth_form_field.dart';
import '../../../widgets/gradient_button.dart';
import '../../../utils/form_validators.dart';
import '../../../services/notification_service.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controllers = _FormControllers();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllers.dispose();
    super.dispose();
  }

Future<void> _signUp() async {
  if (!_validateForm()) return;

  setState(() => _isLoading = true);

  try {
    final repo = ref.read(authRepositoryProvider);
    await repo.signUp(
      _controllers.email.text.trim(),
      _controllers.password.text.trim(),
      _controllers.firstName.text.trim(),
      _controllers.lastName.text.trim(),
    );

    if (mounted) {
      NotificationService.showOverlayMessage(context, 'Account created successfully!');
      context.go('/home');
    }
  } catch (e) {
    if (mounted) {
      NotificationService.showOverlayMessage(context, 'Sign up failed: ${e.toString()}');
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

bool _validateForm() {
  if (!_formKey.currentState!.validate()) {
    NotificationService.showOverlayMessage(context,'Please fill all fields correctly');
    return false;
  }

  if (!_acceptTerms) {
    NotificationService.showOverlayMessage(context,'Please accept the terms and conditions');
    return false;
  }

  if (_controllers.password.text != _controllers.confirmPassword.text) {
    NotificationService.showOverlayMessage(context,'Passwords do not match');
    return false;
  }

  return true;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle: 'Join us and start your journey',
                      icon: Icons.person_add_rounded,
                    ),
                    const SizedBox(height: 40),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildSignInLink(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildNameFields(),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(),
          const SizedBox(height: 24),
          _buildTermsCheckbox(),
          const SizedBox(height: 32),
          _buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: AuthFormField(
            controller: _controllers.firstName,
            label: 'First Name',
            icon: Icons.person_outline,
            validator: (value) => FormValidators.validateName(value, 'First name'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AuthFormField(
            controller: _controllers.lastName,
            label: 'Last Name',
            icon: Icons.person_outline,
            validator: (value) => FormValidators.validateName(value, 'Last name'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AuthFormField(
      controller: _controllers.email,
      label: 'Email Address',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return AuthFormField(
      controller: _controllers.password,
      label: 'Password',
      icon: Icons.lock_outline,
      isPassword: true,
      isPasswordVisible: _isPasswordVisible,
      onPasswordToggle: () {
        setState(() => _isPasswordVisible = !_isPasswordVisible);
      },
      validator: FormValidators.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return AuthFormField(
      controller: _controllers.confirmPassword,
      label: 'Confirm Password',
      icon: Icons.lock_outline,
      isPassword: true,
      isPasswordVisible: _isConfirmPasswordVisible,
      onPasswordToggle: () {
        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
      },
      validator: (value) => FormValidators.validateConfirmPassword(
        value,
        _controllers.password.text,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() => _acceptTerms = value ?? false);
            },
            activeColor: const Color(0xFF667eea),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: const Color(0xFF667eea),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: const Color(0xFF667eea),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GradientButton(
      text: 'Create Account',
      onPressed: _signUp,
      isLoading: _isLoading,
    );
  }

  Widget _buildSignInLink() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to manage form controllers
class _FormControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
  }
}