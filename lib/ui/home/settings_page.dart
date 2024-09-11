import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("Account Settings"),
          _buildListTile(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              // Change Password Logic
            },
          ),
          _buildListTile(
            icon: Icons.phone,
            title: "Update Phone Number",
            onTap: () {
              // Update Phone Number Logic
            },
          ),
          _buildListTile(
            icon: Icons.logout,
            title: "Log Out",
            onTap: () async {
              await _logOut(context); // Call the log-out function
            },
          ),
          const Divider(),
          _buildSectionTitle("App Settings"),
          _buildListTile(
            icon: Icons.notifications,
            title: "Notification Settings",
            onTap: () {
              // Notification Settings Logic
            },
          ),
          _buildListTile(
            icon: Icons.language,
            title: "Change Language",
            onTap: () {
              // Change Language Logic
            },
          ),
          _buildSwitchListTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            value: false, // Replace with dynamic state
            onChanged: (value) {
              // Dark Mode Toggle Logic
            },
          ),
          const Divider(),
          _buildSectionTitle("Privacy"),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {
              // Show Privacy Policy
            },
          ),
          _buildListTile(
            icon: Icons.info,
            title: "Terms & Conditions",
            onTap: () {
              // Show Terms & Conditions
            },
          ),
        ],
      ),
    );
  }

  // Function to handle logout and navigation to the login screen
  Future<void> _logOut(BuildContext context) async {
    try {
      await _auth.signOut(); // Log out from Firebase
      // Navigate to the login screen after successful logout
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      // Handle any errors during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
