import 'package:bungee_ksa/ui/widgets/custom_button.dart';
import 'package:bungee_ksa/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';


class ForgotPasswordDialog extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Forgot Password",
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: "Enter your email",
            icon: Icons.email,
          ),
        ],
      ),
      actions: [
        CustomButton(
          text: "RESET PASSWORD",
          onPressed: () {
            // Reset password logic here
            Navigator.pop(context);
          },
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}
