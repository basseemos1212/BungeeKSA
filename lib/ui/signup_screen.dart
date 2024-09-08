import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  SignUpScreen({super.key});

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
                  'assets/images/logo.png', // Your logo path
                  height: 200,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Let's Get Started!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Create an account to access all features",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                labelText: "Full Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: "Phone",
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  text: "CREATE",
                  onPressed: () {
                    // Sign-Up logic here
                  },
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Sign-In screen
                    Navigator.pop(context); // To go back to Sign-In
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: AppColors.neutral),
                      children: [
                        TextSpan(
                          text: "Login here",
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
