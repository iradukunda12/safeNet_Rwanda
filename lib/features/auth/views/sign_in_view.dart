// lib/views/signin_view.dart
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

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controllers = _FormControllers();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

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
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _controllers.dispose();
    super.dispose();
  }


Future<void> _signIn() async {
  if (!_validateForm()) return;

  setState(() => _isLoading = true);

  try {
    final repo = ref.read(authRepositoryProvider);
    await repo.signIn(
      _controllers.email.text.trim(),
      _controllers.password.text.trim(),
    );

    if (mounted) {
      NotificationService.showOverlayMessage(context,'Welcome back! 🎉');

      await Future.delayed(const Duration(milliseconds: 500));

      GoRouter.of(context).go('/dashboard');  // <---- Redirect to dashboard here
    }
  } catch (e) {
    if (mounted) {
      NotificationService.showOverlayMessage(context,'Sign in failed: ${e.toString()}');
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}



  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      NotificationService.showOverlayMessage(context,'Please fill all fields correctly');
      return false;
    }
    return true;
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AuthBackground(
      child: SafeArea(
        child: _fadeAnimation != null
            ? FadeTransition(
                opacity: _fadeAnimation!,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        const AuthHeader(
                          title: 'Welcome Back',
                          subtitle: 'Sign in to your account',
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: 50),
                        _buildFormCard(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      const AuthHeader(
                        title: 'Welcome Back',
                        subtitle: 'Sign in to your account',
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 50),
                      _buildFormCard(),
                      const SizedBox(height: 24),
                      _buildSignUpLink(),
                      const SizedBox(height: 20),
                    ],
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
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMeAndForgotPassword(),
          const SizedBox(height: 32),
          _buildSignInButton(),
        ],
      ),
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

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
                activeColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Remember me',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Navigate to forgot password screen
            GoRouter.of(context).push('/forgot-password');
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return GradientButton(
      text: 'Sign In',
      onPressed: _signIn,
      isLoading: _isLoading,
    );
  }

  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () => GoRouter.of(context).push('/sign-up'),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const TextSpan(
              text: 'Sign Up',
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
  final email = TextEditingController();
  final password = TextEditingController();

  void dispose() {
    email.dispose();
    password.dispose();
  }
}