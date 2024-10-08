import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for logout functionality
import '../../blocs/bloc/settings_bloc.dart';
import '../../blocs/bloc/theme_bloc.dart';
import '../../blocs/events/settings_events.dart';
import '../../blocs/states/settings_state.dart';
import '../../data/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated localization import
import '../login_screen.dart'; // Import for redirecting to login after logout

class SettingsPage extends StatefulWidget {
  final UserModel userData; // User data passed from previous screen

  const SettingsPage({super.key, required this.userData});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData.name; // Pre-fill with current name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SettingsFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileSection(context), // Profile Section
              const SizedBox(height: 20),
              _buildSettingsOptions(context), // Settings Options
            ],
          );
        },
      ),
    );
  }

  // Profile Section
  Widget _buildProfileSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildProfileImage(), // Profile Image
            const SizedBox(width: 16),
            _buildUserInfo(), // User Info (name, email)
          ],
        ),
      ),
    );
  }

  // Build Profile Image
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () => _selectProfileImage(context),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: widget.userData.profileImageUrl.isNotEmpty
            ? NetworkImage(widget.userData.profileImageUrl)
            : AssetImage('assets/images/logo.png') as ImageProvider, // Use logo if no image
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  // Build User Info (Name and Email)
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.userData.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.userData.email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Settings Options (Change Name, Password, Theme, etc.)
  Widget _buildSettingsOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.changeName),
          trailing: const Icon(Icons.edit),
          onTap: () {
            _showNameChangeDialog(context);
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.changePassword),
          trailing: const Icon(Icons.lock),
          onTap: () {
            _showPasswordChangeDialog(context);
          },
        ),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)!.changeLanguage),
          trailing: const Icon(Icons.language),
          onTap: () {
            final newLocale = Localizations.localeOf(context).languageCode == 'en'
                ? const Locale('ar')
                : const Locale('en');
            BlocProvider.of<SettingsBloc>(context)
                .add(ChangeLanguageRequested(newLocale));
          },
        ),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            final themeMode = state.themeMode;
            return ListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  BlocProvider.of<ThemeBloc>(context)
                      .add(ThemeChanged(value ? ThemeMode.dark : ThemeMode.light));
                },
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)!.logout),
          trailing: const Icon(Icons.exit_to_app,color: Colors.red,),
          onTap: () {
            _logout(context); // Call logout function
          },
        ),
      ],
    );
  }

  // Function to Select Profile Image
  Future<void> _selectProfileImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      BlocProvider.of<SettingsBloc>(context)
          .add(UpdateProfilePictureRequested(image.path));
    }
  }

  // Dialog to Change Name
  void _showNameChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeName),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterNewName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<SettingsBloc>(context)
                    .add(UpdateNameRequested(_nameController.text));
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  // Dialog to Change Password
  void _showPasswordChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changePassword),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterNewPassword,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<SettingsBloc>(context)
                    .add(UpdatePasswordRequested(_passwordController.text));
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log the user out
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>  LoginScreen(), // Redirect to LoginScreen after logout
      ),
    );
  }
}
