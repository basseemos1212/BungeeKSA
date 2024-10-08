import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const OnboardingButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
