import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math'; // For random selection of images

class BarcodePage extends StatefulWidget {
  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final List<String> backgroundImages = [
    'assets/images/1.jpeg',  // Background Image 1
    'assets/images/2.jpg',   // Background Image 2
    'assets/images/3.jpeg',  // Background Image 3
    'assets/images/4.jpg',   // Background Image 4
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userEmail;
  Map<String, bool> expandedState = {};
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    userEmail = _auth.currentUser?.email;
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Classes'),
      ),
      body: userEmail != null && userEmail!.contains('@admin')
          ? Column(
        children: [
          _buildSearchField(), // Add search field
          Expanded(child: _buildAdminUserList()), // Admin user list
        ],
      )
          : _buildUserBookings(), // Show own bookings for normal users
    );
  }

  // Build the search field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Build user list for admin
  // Build user list for admin
  Widget _buildAdminUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        // Filter users by search text
        final users = snapshot.data!.docs.where((userDoc) {
          final userEmail = (userDoc['email'] as String).toLowerCase();
          return userEmail.contains(_searchText);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userId = userDoc.id;
            final userName = userDoc['email'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(userName),
                  trailing: IconButton(
                    icon: Icon(
                      expandedState[userId] == true
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        expandedState[userId] = !(expandedState[userId] ?? false);
                      });
                    },
                  ),
                ),
                if (expandedState[userId] == true)
                  _buildUserBookingsForAdmin(userId), // Fetch user bookings when expanded
              ],
            );
          },
        );
      },
    );
  }


  // Build bookings for a particular user (for admin)
  Widget _buildUserBookingsForAdmin(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('attend', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No bookings available.'),
          );
        }

        final bookings = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true, // To allow nesting in ListView
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final classDetail = bookings[index].data() as Map<String, dynamic>;
            final classId = bookings[index].id;
            return _buildClassCard(context, classDetail, classId);
          },
        );
      },
    );
  }

  // Build booking card with the random background for users (same as normal users view)
  Widget _buildClassCard(BuildContext context, Map<String, dynamic> classDetail, String classId) {
    final userId = _auth.currentUser?.uid;
    final String randomBackgroundImage = backgroundImages[Random().nextInt(backgroundImages.length)];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeDetailPage(
              className: classDetail['className'],
              date: classDetail['date'],
              price: classDetail['price'],
              hour: classDetail['hour'], // Include class hour
              barcodeData: "$userId-$classId", // Pass userId and classId to generate barcode
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: AssetImage(randomBackgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classDetail['className'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Date: ${classDetail['date']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Time: ${classDetail['hour']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Price: ${classDetail['price']} SAR",
                    style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Tap to view barcode",
                style: TextStyle(fontSize: 14, color: Colors.amberAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build bookings for the current user (non-admin view)
  Widget _buildUserBookings() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .where('attend', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No available classes for attendance.'));
        }

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final classDetail = bookings[index].data() as Map<String, dynamic>;
            final classId = bookings[index].id;
            return _buildClassCard(context, classDetail, classId);
          },
        );
      },
    );
  }
}

class BarcodeDetailPage extends StatelessWidget {
  final String className;
  final String date;
  final String hour;
  final int price;
  final String barcodeData;

  const BarcodeDetailPage({
    Key? key,
    required this.className,
    required this.date,
    required this.hour,
    required this.price,
    required this.barcodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              className,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Date: $date",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Time: $hour",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.attach_money, color: Colors.blue, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Price: $price SAR",
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 40),
            BarcodeWidget(
              barcode: Barcode.code128(), // Using Code 128 for barcodes
              data: barcodeData, // The barcode data (userId + classId)
              width: 220,
              height: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan this barcode at the entrance.",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
