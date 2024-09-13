import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // For random background

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  final List<String> backgroundImages = [
    'assets/images/1.jpeg',
    'assets/images/2.jpg',
    'assets/images/3.jpeg',
    'assets/images/4.jpg',
  ];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (userEmail != null && userEmail.contains('@admin')) {
      setState(() {
        isAdmin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isAdmin ? const Text('Users') : const Text('My Bookings'),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: isAdmin ? _buildUserList() : _buildBookingList(),
          ),
        ],
      ),
    );
  }

  // Build the search field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: isAdmin ? 'Search users by email...' : 'Search by class name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Build the booking list for the current user
  Widget _buildBookingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUserBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoBookingsCard();
        }

        final bookings = snapshot.data!.docs.where((booking) {
          final className = booking['className'].toString().toLowerCase();
          return className.contains(_searchText.toLowerCase());
        }).toList();

        bookings.sort((a, b) {
          DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['date']);
          DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['date']);
          return dateB.compareTo(dateA); // Newest first
        });

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: bookings.map((booking) {
            DateTime bookingDate = DateFormat('yyyy-MM-dd').parse(booking['date']);
            return _buildBookingCard(context, booking, bookingDate);
          }).toList(),
        );
      },
    );
  }

  // Build the user list for admin
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users available.'));
        }

        final users = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: users.where((user) {
            final email = user['email'].toString().toLowerCase();
            return email.contains(_searchText.toLowerCase());
          }).map((user) {
            return _buildUserTile(context, user);
          }).toList(),
        );
      },
    );
  }

  // Build individual user tile with expandable bookings
  Widget _buildUserTile(BuildContext context, DocumentSnapshot userDoc) {
    final userId = userDoc.id;
    final userEmail = userDoc['email'];

    return ExpansionTile(
      title: Text(userEmail),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const ListTile(
                title: Text('No bookings available.'),
              );
            }

            final bookings = snapshot.data!.docs;
            return Column(
              children: bookings.map((booking) {
                DateTime bookingDate = DateFormat('yyyy-MM-dd').parse(booking['date']);
                return _buildBookingCard(context, booking, bookingDate);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Stream for fetching real-time booking updates for the current user
  Stream<QuerySnapshot> _getUserBookingsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Build individual booking card
  Widget _buildBookingCard(BuildContext context, DocumentSnapshot booking, DateTime day) {
    bool hasAttended = booking['attend'];
    DateTime now = DateTime.now();

    bool isLate = !hasAttended &&
        now.isAfter(
          DateFormat('yyyy-MM-dd h:mm a').parse('${booking['date']} ${booking['hour']}'),
        );

    final String randomBackgroundImage = backgroundImages[Random().nextInt(backgroundImages.length)];

    return StreamBuilder<DocumentSnapshot>(
      stream: _getClassStream(booking['classDocId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildNoBookingsCard();
        }

        final classData = snapshot.data!;
        final availableSeats = classData['available_times'][booking['date']][booking['hour']] as int;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background Image
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(randomBackgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              // Booking Details
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['className'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Date: ${DateFormat('MMM d, yyyy').format(day)}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time: ${booking['hour']}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Available Seats: $availableSeats",
                      style: TextStyle(
                        fontSize: 14,
                        color: availableSeats == 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusIcon(hasAttended, isLate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Stream to get real-time class data for seat availability
  Stream<DocumentSnapshot> _getClassStream(String classDocId) {
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(classDocId)
        .snapshots();
  }

  // Display message when no bookings exist
  Widget _buildNoBookingsCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'No bookings available',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  // Build icons based on attendance or late status
  Widget _buildStatusIcon(bool hasAttended, bool isLate) {
    if (hasAttended) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else if (isLate) {
      return const Icon(Icons.error, color: Colors.red, size: 24);
    } else {
      return const Icon(Icons.schedule, color: Colors.blue, size: 24);
    }
  }
}
