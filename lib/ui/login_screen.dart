import 'package:bungee_ksa/ui/widgets/forget_password.dart';
import 'package:flutter/material.dart';
import 'onboarding/onboarding_screen.dart';
import '../utils/colors.dart';
import 'signup_screen.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Add your logo image path here
                  height: 200,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Welcome back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Log in to your account",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot password logic here
                    showDialog(context: context, builder: (context) => ForgotPasswordDialog(),);
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  text: "LOG IN",
                  onPressed: () {
                    // Navigate to OnboardingScreen after login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OnboardingScreen()),
                    );
                  },
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Text("Or connect using")),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(
                    icon: Icons.facebook,
                    text: "Facebook",
                    backgroundColor: AppColors.facebookBlue,
                    onPressed: () {
                      // Facebook login logic
                    },
                  ),
                  const SizedBox(width: 16),
                  SocialButton(
                    icon: Icons.g_translate,
                    text: "Google",
                    backgroundColor: AppColors.googleRed,
                    onPressed: () {
                      // Google login logic
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Sign-Up screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: AppColors.neutral),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
