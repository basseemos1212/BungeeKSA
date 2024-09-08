import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text("Bungee KSA"),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          // Handle notifications here
        },
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Image(image: AssetImage('assets/images/logo.png'),height: 35,), 
      ),
    ],
     // Use the primary theme color
  );
}
