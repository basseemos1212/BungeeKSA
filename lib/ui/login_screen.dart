import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/bloc/auth_bloc.dart';
import '../blocs/events/auth_event.dart';
import '../blocs/states/auth_state.dart';
import 'onboarding/onboarding_screen.dart';
import '../utils/colors.dart';
import 'signup_screen.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_button.dart';
import 'widgets/forget_password.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to onboarding if login is successful
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
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
                    controller: emailController,
                    labelText: "Email",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    labelText: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Show Forgot Password dialog
                        showDialog(
                          context: context,
                          builder: (context) => ForgotPasswordDialog(),
                        );
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
                        // Trigger login event
                        BlocProvider.of<AuthBloc>(context).add(
                          LoginRequested(
                            emailController.text,
                            passwordController.text,
                          ),
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
                        icon: Icons.g_translate,
                        text: "Google",
                        backgroundColor: AppColors.googleRed,
                        onPressed: () {
                          // Trigger Google Sign-In
                          // BlocProvider.of<AuthBloc>(context).add(GoogleSignInRequested());
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
          );
        },
      ),
    );
  }
}
