import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../blocs/bloc/auth_bloc.dart';
import '../blocs/events/auth_event.dart';
import '../blocs/states/auth_state.dart';
import '../utils/colors.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';
import 'package:email_validator/email_validator.dart'; // Add email validator package for validation

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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to home screen if sign-up is successful
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/onboarding');
          } else if (state is AuthFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirmPassword = _confirmPasswordController.text.trim();
                        final name = _nameController.text.trim();
                        final phone = _phoneController.text.trim();

                        // Email validation
                        if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All fields must be filled.')),
                          );
                          return;
                        }

                        if (!EmailValidator.validate(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid email address.')),
                          );
                          return;
                        }

                        // Block emails that contain 'admin' or 'manager'
                        if (email.contains('@admin') || email.contains('@manager')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email cannot contain @admin or @manager.')),
                          );
                          return;
                        }

                        // Password validation
                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 6 characters.')),
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match.')),
                          );
                          return;
                        }

                        // Check if the phone number already exists
                        final QuerySnapshot phoneCheck = await FirebaseFirestore.instance
                            .collection('users')
                            .where('phone', isEqualTo: phone)
                            .get();

                        if (phoneCheck.docs.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number already in use.')),
                          );
                          return;
                        }

                        // Trigger sign-up event (Firebase will check for existing emails)
                        BlocProvider.of<AuthBloc>(context).add(
                          SignUpRequested(email, password, name, phone),
                        );
                      },
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate back to Sign-In screen
                        Navigator.pop(context); // Go back to login
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
          );
        },
      ),
    );
  }
}
