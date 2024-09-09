import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc/auth_bloc.dart';
import '../../blocs/events/auth_event.dart';
import '../../blocs/states/auth_state.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'barcode_page.dart';
import 'settings_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Track the selected index

  // List of widgets representing each screen content
  final List<Widget> _pages = [
    HomePage(),
    BookingPage(),
    BarcodePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data once the HomeScreen is initialized
    String? uid = FirebaseAuth.instance.currentUser?.uid; // Get current user UID
    if (uid != null) {
      context.read<AuthBloc>().add(FetchUserDataRequested(uid)); // Trigger event to fetch user data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserDataSuccess) {
            // Pass the user data to the child pages
            return IndexedStack(
              index: _currentIndex,
              children: _pages.map((page) {
                return _injectUserData(page, state.user); // Inject user data into pages
              }).toList(),
            );
          } else if (state is UserDataFailure) {
            return Center(child: Text(state.error));
          } else {
            return const Center(child: Text("Welcome to Bungee KSA! "));
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Function to inject user data into each page
  Widget _injectUserData(Widget page, dynamic userData) {
    print(userData);
    if (page is HomePage) {
      return HomePage();
    } else if (page is BookingPage) {
      return BookingPage();
    } else if (page is BarcodePage) {
      return BarcodePage();
    } else if (page is SettingsPage) {
      return SettingsPage();
    }
    return page;
  }
}
