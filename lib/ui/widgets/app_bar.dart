import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Row(
      children: [
        Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Image(image: AssetImage('assets/images/logo.png'),height: 35,), 
      ),
        Text("Bungee KSA"),
      ],
    ),
   
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          // Handle notifications here
        },
      ),
    
    ],
     // Use the primary theme color
  );
}
